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

resource "aws_ecs_cluster" "default" {
  name = "${var.project}-${var.environment}-ecsCluster"

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
  service_name = "django-playground"
}

resource "aws_ecs_service" "default" {
  name    = local.service_name
  cluster = aws_ecs_cluster.default.id

  # 希望するタスクの数
  desired_count = 1

  # EC2 or FARGATE
  launch_type = "FARGATE"

  load_balancer {
    target_group_arn = var.alb_target_group_arn
    container_name   = local.service_name
    container_port   = 80
  }

  network_configuration {
    subnets         = var.public_subnet_ids
    security_groups = [var.ecs_security_group_id]

    # これはfalseでもいいかも
    assign_public_ip = true
  }

  task_definition = aws_ecs_task_definition.main.arn

  # CIからデプロイのたびにタスク定義は更新される（新しいimageを参照する）
  # terraformがタスク定義を管理しつづけていると「タスク定義が変更されちゃった！戻さなきゃ」になってしまうので、タスク定義の変更は無視するよう設定する
  lifecycle {
    ignore_changes = [task_definition]
  }
}


# ==========================================================================================================================
# task definition
# ==========================================================================================================================

resource "aws_ecs_task_definition" "main" {
  family                   = "django-playground"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "1024"
  memory                   = "3072"

  # タスクを起動するときに権限が必要
  execution_role_arn = data.aws_iam_role.ecs_task_execution.arn

  runtime_platform {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }

  container_definitions = jsonencode([
    {
      name      = "django-playground"
      image     = "nginx:latest" # 仮のイメージを指定する。後からCIによって適切なイメージを指定した新しいリビジョンが積まれる
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
      secrets = [
        {
          name      = "DATABASE_HOST"
          valueFrom = var.database_host_ssm_parameter_arn
        },
        {
          name      = "DATABASE_PORT"
          valueFrom = var.database_port_ssm_parameter_arn
        },
        {
          name      = "DATABASE_NAME"
          valueFrom = var.database_name_ssm_parameter_arn
        },
        {
          name      = "DATABASE_USERNAME"
          valueFrom = var.database_username_ssm_parameter_arn
        },
        {
          name      = "DATABASE_PASSWORD"
          valueFrom = var.database_password_ssm_parameter_arn
        },
      ]
    }
  ])
}


# ==========================================================================================================================
# role
# ==========================================================================================================================

# ecs実行ロール（aws管理）
data "aws_iam_role" "ecs_task_execution" {
  name = "ecsTaskExecutionRole"
}

# parameter storeからDB接続情報を取得できるpolicy
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

# parameter storeからDB接続情報を取得できるpolicyを、デフォルトのecs実行ロールに付け加える
resource "aws_iam_role_policy_attachment" "ecs_task_execution__get_parameter_store" {
  role       = data.aws_iam_role.ecs_task_execution.name
  policy_arn = aws_iam_policy.get_parameter_store.arn
}
