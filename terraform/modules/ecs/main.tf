
# ==========================================================================================================================
# ECR
# ==========================================================================================================================

resource "aws_ecr_repository" "default" {
  name = "django-playground"

  # イメージのタグを後から変更可能にするかどうか
  # たぶん、CIからイメージをpushするときにリビジョンを更新するためにMUTABLEな必要がある
  image_tag_mutability = "MUTABLE"

  tags = {
    Name        = "${var.project}-${var.environment}-ecr"
    Project     = var.project
    Environment = var.environment
  }
}


# ==========================================================================================================================
# cluster
# ==========================================================================================================================

locals {
  cluster_name = "${var.project}-${var.environment}"
}

resource "aws_ecs_cluster" "default" {
  name = local.cluster_name

  tags = {
    Name        = "${var.project}-${var.environment}-ecsCluster"
    Project     = var.project
    Environment = var.environment
  }
}


# ==========================================================================================================================
# service
# ==========================================================================================================================

locals {
  # workerができたら-app/-workerとかで区別する
  service_app = "${local.cluster_name}-app"

  task_definition_app       = "${local.cluster_name}-app"
  task_definition_migration = "${local.cluster_name}-migration"

  task_definition_app__container_main       = "${local.task_definition_app}-main"
  task_definition_migration__container_main = "${local.task_definition_migration}-main"
}

resource "aws_ecs_service" "app" {
  name    = local.service_app
  cluster = aws_ecs_cluster.default.id

  # 希望するタスクの数
  desired_count = 1

  # EC2 or FARGATE
  launch_type = "FARGATE"

  load_balancer {
    target_group_arn = var.alb_target_group_arn
    container_name   = local.task_definition_app__container_main
    container_port   = 80
  }

  network_configuration {
    subnets         = var.public_subnet_ids
    security_groups = [var.ecs_security_group_id]

    # これはfalseでもいいかも
    assign_public_ip = true
  }

  task_definition = aws_ecs_task_definition.app.arn

  # CIからデプロイのたびにタスク定義は更新される（新しいimageを参照する）
  # terraformがタスク定義を管理しつづけていると「タスク定義が変更されちゃった！戻さなきゃ」になってしまうので、タスク定義の変更は無視するよう設定する
  lifecycle {
    ignore_changes = [task_definition]
  }
}


# ==========================================================================================================================
# task definition
# ==========================================================================================================================

resource "aws_ecs_task_definition" "app" {
  family                   = local.task_definition_app
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "1024"
  memory                   = "3072"

  # タスクを起動するときに権限が必要
  execution_role_arn = aws_iam_role.ecs_task_execution.arn

  # 起動されたタスクのプロセスに付与される権限を定義する
  # 少なくともstaticファイルのバージョニングに用いるmanifestの取得のため、s3にアクセスできる必要がある
  # S3ManifestStaticStorage に custom_domain として cloudfront のドメインを渡しているが、これは template での static タグの解決に利用するだけであり、
  # collectstatic や manifest の取得においては直接s3に接続するものと思われる。
  task_role_arn = aws_iam_role.ecs_task.arn

  runtime_platform {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }

  # ひとつのタスクは、ひとつのEC2や、相当するfargate環境上で実行される。
  # ひとつのタスクの中で、複数のコンテナを立ち上げることができる。
  # アプリケーション自体と、ログ送信のためのコンテナなど。

  # fileだとjsonを読み込むだけだが、templatefileだと変数を渡すことができる
  container_definitions = templatefile("${path.module}/task_definitions.json", {
    name              = local.task_definition_app__container_main,
    database_host     = var.database_host_ssm_parameter_arn,
    database_port     = var.database_port_ssm_parameter_arn,
    database_name     = var.database_name_ssm_parameter_arn,
    database_username = var.database_username_ssm_parameter_arn,
    database_password = var.database_password_ssm_parameter_arn
    domain_name       = var.cloudfront_domain
  })
}

resource "aws_ecs_task_definition" "migration" {
  family                   = local.task_definition_migration
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "1024"
  memory                   = "3072"

  # タスクを起動するときに権限が必要
  execution_role_arn = aws_iam_role.ecs_task_execution.arn

  runtime_platform {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }

  container_definitions = templatefile("${path.module}/task_definitions.json", {
    name              = local.task_definition_migration__container_main,
    database_host     = var.database_host_ssm_parameter_arn,
    database_port     = var.database_port_ssm_parameter_arn,
    database_name     = var.database_name_ssm_parameter_arn,
    database_username = var.database_username_ssm_parameter_arn,
    database_password = var.database_password_ssm_parameter_arn,
    domain_name       = var.cloudfront_domain
  })
}


# ==========================================================================================================================
# execution role
# ==========================================================================================================================

# ロールそのもの
resource "aws_iam_role" "ecs_task_execution" {
  name               = "ecsTaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.assume.json
}

# どういう人ならそのロールを引き受けられるか
data "aws_iam_policy_document" "assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      # ユーザーではなくリソースがロールを引き受ける場合は"Service"を指定する
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# aws管理のポリシーをアタッチ
resource "aws_iam_role_policy_attachment" "ecs_task_execution__default" {
  role = aws_iam_role.ecs_task_execution.name
  # aws管理ポリシーは、コンソールからarnをコピペすればOK
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# parameter storeからDB接続情報を取得できるカスタムpolicy
resource "aws_iam_policy" "get_parameter_store" {
  name        = "CustomSSMPolicy"
  description = "Policy for accessing SSM parameters for ECS tasks"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters"
        ]
        Effect = "Allow"
        Resource = [
          var.database_host_ssm_parameter_arn,
          var.database_port_ssm_parameter_arn,
          var.database_name_ssm_parameter_arn,
          var.database_username_ssm_parameter_arn,
          var.database_password_ssm_parameter_arn
        ]
      }
    ]
  })
}

# アタッチする
resource "aws_iam_role_policy_attachment" "ecs_task_execution__get_parameter_store" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = aws_iam_policy.get_parameter_store.arn
}


# ==========================================================================================================================
# task role
# ==========================================================================================================================

# ロールそのもの
resource "aws_iam_role" "ecs_task" {
  name = "ecsTaskRole"
  # assume policyはタスク実行ロールと共通
  assume_role_policy = data.aws_iam_policy_document.assume.json
}

# s3にアクセスできるカスタムpolicy
resource "aws_iam_policy" "s3" {
  name        = "CustomS3AccessPolicy"
  description = "Policy for accessing S3 for ECS tasks"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Effect   = "Allow"
        Resource = ["arn:aws:s3:::*"]
      }
    ]
  })
}

# アタッチする
resource "aws_iam_role_policy_attachment" "ecs_task__s3" {
  role       = aws_iam_role.ecs_task.name
  policy_arn = aws_iam_policy.s3.arn
}
