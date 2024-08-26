# ==========================================================================================================================
# ALB
# ==========================================================================================================================

# alb [1] <- [n] listener [1] -> [1] target group [1] <- [n] target group attachment [n] -> [1] ec2 instance
resource "aws_lb" "default" {
  name = "${var.project}-${var.environment}-alb"

  # インターネットからのアクセスを捌くのでinternalはfalse
  internal = false

  # ALB/NLBなどの指定
  load_balancer_type = "application"

  security_groups = [var.alb_security_group_id]
  subnets         = var.public_subnet_ids

  enable_deletion_protection = false
}

# HTTPをport:80で受け付ける
# cloudfrontでhttpsでのリダイレクトを強制するようにしたら、ALBまではhttpsが到達しないはずだから、httpリスナーは不要かもしれない
resource "aws_lb_listener" "alb_listener_http" {
  load_balancer_arn = aws_lb.default.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    # そのまま転送するよ
    type             = "forward"
    target_group_arn = aws_lb_target_group.default.arn
  }
}

# ALBでSSL終端するとはすなわち、ALBのhttpsリスナーにACMを登録すること！！
resource "aws_lb_listener" "alb_listener_https" {
  load_balancer_arn = aws_lb.default.arn
  port              = 443
  protocol          = "HTTPS"

  # see: https://www.youtube.com/watch?v=2QHdvEHN050
  ssl_policy      = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn = var.certificate_arn

  default_action {
    # そのまま転送するよ
    type             = "forward"
    target_group_arn = aws_lb_target_group.default.arn
  }
}


# ==========================================================================================================================
# target group
# ==========================================================================================================================

resource "aws_lb_target_group" "default" {
  name   = "${var.project}-${var.environment}-albTg"
  vpc_id = var.vpc_id

  # targetの種類を以下のいずれかで指定する
  # - instance : ec2 instance
  # - ip : ip address（ECS taskの場合はこれ）
  # - lambda : lambda function
  target_type = "ip"
  port        = 80
  protocol    = "HTTP"

  # target を target group から解除した後も、実行していた処理をどれくらい待つか、という設定
  # 本番では300sec程度にしておくのがよいが、デモ用途でさっさと畳みたいので0にする
  deregistration_delay = 0

  health_check {
    path = "/"

    # health checkが連続してn回成功したらhealthyとみなす
    healthy_threshold = 2

    # health checkが連続してn回失敗したらunhealthyとみなす
    unhealthy_threshold = 2

    timeout  = 15
    interval = 30

    # DBの設定がまだできておらず200を返すページがないので、一時的に404でhealthy判定とする
    matcher = 404

    # それぞれのtargetで指定されたportに対してhealth checkを行う
    port = "traffic-port"

    protocol = "HTTP"
  }

  tags = {
    Name        = "${var.project}-${var.environment}-albTargetGroup"
    Project     = var.project
    Environment = var.environment
  }
}


# ==========================================================================================================================
# route53
# ==========================================================================================================================

# SSL証明はドメインに対する証明である
# なのでSSL終端（ここではALB）はドメインを割り当てられている必要がある
resource "aws_route53_record" "alb" {
  zone_id = var.route53_zone_id
  name    = "django-playground-${var.environment}-alb.${var.domain}"

  # Aレコードはipアドレス/AWSリソースいずれかを指定できる
  type = "A"
  alias {
    name    = aws_lb.default.dns_name
    zone_id = aws_lb.default.zone_id

    # ヘルスチェックをするかどうか
    evaluate_target_health = true
  }
}
