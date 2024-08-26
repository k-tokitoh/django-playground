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
