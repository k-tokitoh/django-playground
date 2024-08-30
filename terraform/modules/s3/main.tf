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

# policyを付与する交差テーブル的なresource
resource "aws_s3_bucket_policy" "static" {
  bucket = aws_s3_bucket.static.bucket
  policy = data.aws_iam_policy_document.static.json
}

data "aws_iam_policy_document" "static" {
  # cloudfrontからのアクセスを許可
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.default.iam_arn]
    }
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${aws_s3_bucket.static.bucket}/*"]
  }

  # VPCEからのアクセスを許可
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${aws_s3_bucket.static.bucket}/*"]
    condition {
      test     = "StringEquals"
      variable = "aws:sourceVpce"
      values   = [aws_vpc_endpoint.s3.id]
    }
  }
}

# cloudfrontからs3にアクセスする場合にどういう立場でもってアクセスするかを定義する
resource "aws_cloudfront_origin_access_identity" "default" {
  comment = "${var.project}-${var.environment}"
}

# ECRからcloudfrontに対して、インターネットを経由せずにアクセスするためにVPCエンドポイントを設置する
resource "aws_vpc_endpoint" "s3" {
  # このVPCに対して設置するよ（internet gatewayみたいな感じ）
  vpc_id            = var.vpc_id
  vpc_endpoint_type = "Gateway"

  # ここに向けて通信を送出するよ（VPCEはAWSリソースにアクセスするものなので、service_nameの指定となる）
  service_name = "com.amazonaws.us-east-1.s3"

  # ルートテーブルは、subnetから外にでるときに「このip宛の通信はここに送るよ」とリストしたもの
  # route_table_ids を指定すると、指定したルートテーブルに「このipに対する通信はVPCEに送るよ」と登録してくれる
  # 「このip」の部分は、"com.amazonaws.us-east-1.s3"に対応するipをawsでよしなに管理してくれる（これをprefix listと呼ぶ）
  route_table_ids = [var.public_route_table_id]

  tags = {
    Name    = "${var.project}-${var.environment}-s3"
    Project = var.project
    Env     = var.environment
  }
}
