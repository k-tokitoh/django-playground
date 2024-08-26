# READMEに記載のとおりimportする
resource "aws_acm_certificate" "existing" {
  domain_name = "*.${var.domain}"

  lifecycle {
    prevent_destroy = true
  }
}
