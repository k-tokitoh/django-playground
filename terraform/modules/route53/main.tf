# ==========================================================================================================================
# zone
# ==========================================================================================================================

locals {
  domain = "k-tokitoh.net"
}

# READMEに記載のとおり、手動で作成したzoneをimportしてこのリソースとして管理する
resource "aws_route53_zone" "existing" {
  # ドメイン名
  name    = local.domain
  comment = "HostedZone created by Route53 Registrar"

  # terraform destroyで削除しない
  force_destroy = false
}

resource "aws_route53_record" "route53_record" {
  zone_id = aws_route53_zone.existing.zone_id
  name    = "django-playground-${var.environment}.${local.domain}"

  # Aレコードはipアドレス/AWSリソースいずれかを指定できる
  type = "A"
  alias {
    name    = var.alb.dns_name
    zone_id = var.alb.zone_id

    # ヘルスチェックをするかどうか
    evaluate_target_health = true
  }
}
