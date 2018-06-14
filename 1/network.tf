#=============================================================================
#   EC2 + RDS構成用のVPC、サブネット等一式をつくる
#=============================================================================

# 変数定義
variable "system_name" {}

# 環境変数 AWS_ACCESS_KEY_ID と AWS_SECRET_ACCESS_KEY が参照される
provider "aws" {
    region = "ap-northeast-1"
}

#=============================================================================
#   VPC, Subnet
#=============================================================================
resource "aws_vpc" "vpc1" {
    cidr_block           = "10.6.0.0/16"
    instance_tenancy     = "default"
    enable_dns_support   = true
    enable_dns_hostnames = true
    tags {
        Name = "${var.system_name}-vpc"
    }
}

resource "aws_subnet" "subnet_public1" {
    vpc_id                  = "${aws_vpc.vpc1.id}"
    cidr_block              = "10.6.1.0/24"
    availability_zone       = "ap-northeast-1a"
    map_public_ip_on_launch = true
    tags {
        Name = "${var.system_name}-public1"
    }
}

resource "aws_subnet" "subnet_public2" {
    vpc_id                  = "${aws_vpc.vpc1.id}"
    cidr_block              = "10.6.2.0/24"
    availability_zone       = "ap-northeast-1c"
    map_public_ip_on_launch = true
    tags {
        Name = "${var.system_name}-public2"
    }
}


resource "aws_subnet" "subnet_private1" {
    vpc_id            = "${aws_vpc.vpc1.id}"
    cidr_block        = "10.6.3.0/24"
    availability_zone = "ap-northeast-1a"
    tags {
        Name = "${var.system_name}-private1"
    }
}

resource "aws_subnet" "subnet_private2" {
    vpc_id            = "${aws_vpc.vpc1.id}"
    cidr_block        = "10.6.4.0/24"
    availability_zone = "ap-northeast-1c"
    tags {
        Name = "${var.system_name}-private2"
    }
}

resource "aws_internet_gateway" "gw1" {
    vpc_id = "${aws_vpc.vpc1.id}"
    tags {
        Name = "${var.system_name}-gw"
    }
}

resource "aws_route_table" "public_rtb1" {
    vpc_id = "${aws_vpc.vpc1.id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.gw1.id}"
    }
    tags {
        Name = "${var.system_name}-rtb"
    }
}

resource "aws_route_table_association" "route_table_association_public1" {
    subnet_id      = "${aws_subnet.subnet_public1.id}"
    route_table_id = "${aws_route_table.public_rtb1.id}"
}

resource "aws_route_table_association" "route_table_association_public2" {
    subnet_id      = "${aws_subnet.subnet_public2.id}"
    route_table_id = "${aws_route_table.public_rtb1.id}"
}

##=============================================================================
##   セキュリティグループ app
##=============================================================================
resource "aws_security_group" "ec2_sg" {
    name        = "${var.system_name}-sg"
    description = "for EC2"
    vpc_id      = "${aws_vpc.vpc1.id}"
    tags {
        Name = "${var.system_name}-sg"
    }
}

# ICMPを許可
resource "aws_security_group_rule" "icmp" {
    type              = "ingress"
    from_port         = -1
    to_port           = -1
    protocol          = "icmp"
    cidr_blocks       = ["0.0.0.0/0"]
    security_group_id = "${aws_security_group.ec2_sg.id}"
}

# sshを許可
resource "aws_security_group_rule" "ssh" {
    type              = "ingress"
    from_port         = 22
    to_port           = 22
    protocol          = "tcp"
    cidr_blocks       = ["0.0.0.0/0"]
    security_group_id = "${aws_security_group.ec2_sg.id}"
}

# httpを許可
resource "aws_security_group_rule" "web" {
    type              = "ingress"
    from_port         = 80
    to_port           = 80
    protocol          = "tcp"
    cidr_blocks       = ["0.0.0.0/0"]
    security_group_id = "${aws_security_group.ec2_sg.id}"
}

# Outboundを明示的に作成しないといけない
resource "aws_security_group_rule" "all" {
    type              = "egress"
    from_port         = 0
    to_port           = 65535
    protocol          = "tcp"
    cidr_blocks       = ["0.0.0.0/0"]
    security_group_id = "${aws_security_group.ec2_sg.id}"
}

#=============================================================================
#   セキュリティグループ db
#=============================================================================
resource "aws_security_group" "rds_sg" {
    name        = "${var.system_name}-rds-sg"
    description = "for RDS"
    vpc_id      = "${aws_vpc.vpc1.id}"
    tags {
        Name = "${var.system_name}-rds-sg"
    }
}

resource "aws_security_group_rule" "db" {
    type                     = "ingress"
    from_port                = 5432
    to_port                  = 5432
    protocol                 = "tcp"
    #source_security_group_id = "${aws_security_group.ec2_sg.id}"
    #cidr_blocks              = ["10.6.1.0/24", "10.6.2.0/24"]
    cidr_blocks              = ["${aws_subnet.subnet_public1.cidr_block}", "${aws_subnet.subnet_public2.cidr_block}"]
    security_group_id        = "${aws_security_group.rds_sg.id}"
}

#=============================================================================
#   DBサブネットグループ
#=============================================================================
resource "aws_db_subnet_group" "db_subnet_group" {
    name        = "${var.system_name}-db-sg"
    description = "for RDS"
    subnet_ids  = ["${aws_subnet.subnet_private1.id}", "${aws_subnet.subnet_private2.id}"]
    tags {
        Name = "${var.system_name}-db-sg"
    }
}
