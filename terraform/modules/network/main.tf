# ==========================================================================================================================
# VPC
# ==========================================================================================================================

resource "aws_vpc" "default" {
  # 192.168.0.0は一般にprivate ip addressの範囲として使われる（public ip addressとしては利用されない）
  # 8*4の32bitのうち、上位20bitがネットワークアドレス、下位12bitがホストアドレス
  # すなわち、このcidrでは2^12=4096個のip addressを利用できる（192.168.0.0 ~ 192.168.15.255）
  # NNNN NNNN . NNNN NNNN . NNNN HHHH . HHHH HHHH
  # 1100 0000 . 1010 1000 . 0000 xxxx . xxxx xxxx
  cidr_block = "192.168.0.0/20"

  # このvpc内で起動するec2インスタンスをどう配置するか
  # - default: 共有ハードウェアを利用する
  # - dedicated: 自身のAWSアカウントのみから利用されるよう、ハードウェアを専有する。どの物理ホストかは指定しない
  # - host: 特定の専有された物理ホストにインスタンスを配置する
  instance_tenancy = "default"

  # DNSサポートが有効だと、そのVPC内のec2インスタンスやその他のリソースが、DNSクエリを解決できるようになる。
  # つまり、ec2インスタンスなどから他のリソースに対してドメイン名に基づくアクセスが可能になる
  enable_dns_support = true

  # そのVPC内のec2インスタンスに対して、DNSホスト名を割り当てるかどうか
  enable_dns_hostnames = true

  # このVPC内で新しいIPv6 CIDRブロックを生成して、そのCIDRブロックをVPCに割り当てるかどうか
  # 割り当てた場合には、そのVPC内のインスタンスにはIPv6アドレスが割り当てられることになる
  assign_generated_ipv6_cidr_block = false

  tags = {
    Name    = "${var.project}-${var.environment}-vpc"
    Project = var.project
    Env     = var.environment
  }
}


# ==========================================================================================================================
# subnet
# ==========================================================================================================================

resource "aws_subnet" "public_1a" {
  vpc_id            = aws_vpc.default.id
  availability_zone = "us-east-1a"

  # VPCに当てたcidr blockは下位12bitがホスト部だった
  # そのうち上位4bitをサブネットの指定のために利用し、下位8bitをサブネット内で利用可能なアドレスとして利用する
  # NNNN NNNN . NNNN NNNN . NNNN SSSS . HHHH HHHH
  # 1100 0000 . 1010 1000 . 0000 0001 . xxxx xxxx
  cidr_block = "192.168.1.0/24"

  # サブネット内のec2に対して、デフォルトでpublic ip addressを割り当てるかどうか
  map_public_ip_on_launch = false

  tags = {
    Name    = "${var.project}-${var.environment}-publicSubnet1a"
    Project = var.project
    Env     = var.environment
    Type    = "public"
  }
}

resource "aws_subnet" "public_1b" {
  vpc_id            = aws_vpc.default.id
  availability_zone = "us-east-1b"

  # VPCに当てたcidr blockは下位12bitがホスト部だった
  # そのうち上位4bitをサブネットの指定のために利用し、下位8bitをサブネット内で利用可能なアドレスとして利用する
  # NNNN NNNN . NNNN NNNN . NNNN SSSS . HHHH HHHH
  # 1100 0000 . 1010 1000 . 0000 0010 . xxxx xxxx
  cidr_block = "192.168.2.0/24"

  # サブネット内のec2に対して、デフォルトでpublic ip addressを割り当てるかどうか
  map_public_ip_on_launch = false

  tags = {
    Name    = "${var.project}-${var.environment}-publicSubnet1b"
    Project = var.project
    Env     = var.environment
    Type    = "public"
  }
}

resource "aws_subnet" "private_1a" {
  vpc_id            = aws_vpc.default.id
  availability_zone = "us-east-1a"

  # VPCに当てたcidr blockは下位12bitがホスト部だった
  # そのうち上位4bitをサブネットの指定のために利用し、下位8bitをサブネット内で利用可能なアドレスとして利用する
  # NNNN NNNN . NNNN NNNN . NNNN SSSS . HHHH HHHH
  # 1100 0000 . 1010 1000 . 0000 0011 . xxxx xxxx
  cidr_block = "192.168.3.0/24"

  # サブネット内のec2に対して、デフォルトでpublic ip addressを割り当てるかどうか
  map_public_ip_on_launch = false

  tags = {
    Name    = "${var.project}-${var.environment}-privateSubnet1a"
    Project = var.project
    Env     = var.environment
    Type    = "private"
  }
}

resource "aws_subnet" "private_1b" {
  vpc_id            = aws_vpc.default.id
  availability_zone = "us-east-1b"

  # VPCに当てたcidr blockは下位12bitがホスト部だった
  # そのうち上位4bitをサブネットの指定のために利用し、下位8bitをサブネット内で利用可能なアドレスとして利用する
  # NNNN NNNN . NNNN NNNN . NNNN SSSS . HHHH HHHH
  # 1100 0000 . 1010 1000 . 0000 0100 . xxxx xxxx
  cidr_block = "192.168.4.0/24"

  # サブネット内のec2に対して、デフォルトでpublic ip addressを割り当てるかどうか
  map_public_ip_on_launch = false

  tags = {
    Name    = "${var.project}-${var.environment}-privateSubnet1c"
    Project = var.project
    Env     = var.environment
    Type    = "private"
  }
}


# ==========================================================================================================================
# route table
# ==========================================================================================================================

# vpc [1] - [n] route table [1] - [n] subnet
# route talbeは複数のrouteをもつ
# routeは、そのsubnetから外へと通信する際に、送信先となるipアドレス（の範囲）と、送信先がその範囲に該当した場合にどこに向けてパケットを送出するかを定めたルールである
# subnetにおいて送信されたパケットは、そのsubnetに関連付けられたroute tableに基づいて、順次routeと照らし合わせ、該当したrouteに規定されたtargetに向けて送出される
# route tableはデフォルトで、紐づいたVPCのcidr blockを送信先ipアドレス範囲とし、local（=VPC自身）をtargetとするrouteを持つ
# つまり、以下のroute tableはデフォルトで以下のrouteを持つ
# 送信先ipアドレス範囲: 192.168.0.0/20, ターゲット: local

# 例えば以下では aws_subnet.public_1a には aws_route_table.public が紐づけられる
# なので aws_subnet.public_1a から送信されたパケットは aws_route_table.public に基づいてroutingされる
# 送信先が192.168.2.50であれば、192.168.0.0/20に該当するので、そのパケットはlocal（=このvpc自身）に向けて送出される
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.default.id

  tags = {
    Name    = "${var.project}-${var.environment}-publicRouteTable"
    Project = var.project
    Env     = var.environment
    Type    = "public"
  }
}

resource "aws_route_table_association" "public_1a" {
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public_1a.id
}

resource "aws_route_table_association" "public_1b" {
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public_1b.id
}


# ==========================================================================================================================
# internet gateway
# ==========================================================================================================================

resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id

  tags = {
    Name    = "${var.project}-${var.environment}-internetGateway"
    Project = var.project
    Env     = var.environment
  }
}

# aws_route_table.public にインターネットゲートウェイへのルートを追加登録する
resource "aws_route" "internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.default.id
}


# ==========================================================================================================================
# security group
# ==========================================================================================================================

# ベストプラクティスがわからないが、各モジュールでセキュリティグループを定義すると、in/outで循環依存が生じてしまうので、ここでまとめて定義している

################################################################################### alb

resource "aws_security_group" "alb" {
  name = "${var.project}-${var.environment}-securityGroupAlb"
  # descriptionは指定がないとランダムな文字列が入ってしまうため指定しておく
  description = "security group for ALB"

  vpc_id = aws_vpc.default.id

  tags = {
    Name    = "${var.project}-${var.environment}-securityGroupAlb"
    Project = var.project
    Env     = var.environment
  }
}

data "aws_ec2_managed_prefix_list" "cloudfront" {
  name = "com.amazonaws.global.cloudfront.origin-facing"
}

resource "aws_security_group_rule" "alb_in_https" {
  security_group_id = aws_security_group.alb.id

  type            = "ingress"
  protocol        = "tcp"
  from_port       = 443
  to_port         = 443
  prefix_list_ids = [data.aws_ec2_managed_prefix_list.cloudfront.id]
}

resource "aws_security_group_rule" "alb_out_http" {
  security_group_id = aws_security_group.alb.id

  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 80
  to_port                  = 80
  source_security_group_id = aws_security_group.ecs.id
}

################################################################################### ecs

resource "aws_security_group" "ecs" {
  name = "${var.project}-${var.environment}-securityGroupEcs"
  # descriptionは指定がないとランダムな文字列が入ってしまうため指定しておく
  description = "security group for ECS"

  vpc_id = aws_vpc.default.id

  tags = {
    Name    = "${var.project}-${var.environment}-securityGroupEcs"
    Project = var.project
    Env     = var.environment
  }
}

# albからのアクセスを許可する
resource "aws_security_group_rule" "ecs_in_http" {
  security_group_id = aws_security_group.ecs.id

  type = "ingress"

  # "-1"で任意のプロトコルを許可できる。その場合はfrom_port/to_portは0とすること
  protocol                 = "tcp"
  from_port                = 80
  to_port                  = 80
  source_security_group_id = aws_security_group.alb.id
}

# ECRからimageをpullしたり、S3にアクセスしたりするときはinternet gateway経由で、httpsみたい
resource "aws_security_group_rule" "ecs_out_https" {
  security_group_id = aws_security_group.ecs.id

  type        = "egress"
  protocol    = "tcp"
  from_port   = 443
  to_port     = 443
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ecs_out_mysql" {
  security_group_id = aws_security_group.ecs.id

  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 3306
  to_port                  = 3306
  source_security_group_id = aws_security_group.db.id
}

################################################################################### db

resource "aws_security_group" "db" {
  name        = "${var.project}-${var.environment}-dbSecurityGroup"
  description = "security group for db"

  vpc_id = aws_vpc.default.id

  tags = {
    Name    = "${var.project}-${var.environment}-dbSecurityGroup"
    Project = var.project
    Env     = var.environment
  }
}

resource "aws_security_group_rule" "db_in_tcp3306" {
  security_group_id = aws_security_group.db.id

  type      = "ingress"
  protocol  = "tcp"
  from_port = 3306
  to_port   = 3306

  source_security_group_id = aws_security_group.ecs.id
}

