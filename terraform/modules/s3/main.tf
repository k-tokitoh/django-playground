resource "random_string" "s3_unique_key" {
  length = 6
  # 特殊文字
  special = false
  upper   = false
  lower   = true
  numeric = false
}

# ==========================================================================================================================
# static bucket
# ==========================================================================================================================

# 配信したい静的 = staticなファイルを配置する、privateなバケット
resource "aws_s3_bucket" "static" {
  # バケット名
  bucket = "${lower(var.project)}-${lower(var.environment)}-static-${random_string.s3_unique_key.result}"
}

resource "aws_s3_bucket_public_access_block" "s3_static_bucket_public_access_block" {
  bucket = aws_s3_bucket.static.bucket

  # 「パブリックアクセスOKだよ」というACLの追加をブロックする
  # TODO: あとで直す
  block_public_acls = false

  # 「パブリックアクセスOKだよ」というACLが元から存在していた場合、その許可を無視する（パブリックアクセスを禁じる）
  # TODO: あとで直す
  ignore_public_acls = false

  # 「パブリックアクセスOKだよ」というpolicyの追加をブロックする
  # TODO: あとで直す
  block_public_policy = false

  # 「パブリックアクセスOKだよ」というpolicyが元から存在していた場合、その許可を無視する（パブリックアクセスを禁じる）
  # TODO: あとで直す
  restrict_public_buckets = false
}

# TODO: あとで直す（途中段階で確認しやすいように入れただけ）
resource "aws_s3_bucket_policy" "static_all" {
  bucket = aws_s3_bucket.static.bucket
  policy = data.aws_iam_policy_document.static_all.json
}

data "aws_iam_policy_document" "static_all" {
  statement {
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${aws_s3_bucket.static.bucket}/*"]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}
