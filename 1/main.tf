#=============================================================================
#   EC2 + RDS構成用のVPC、サブネット等一式をつくる
#=============================================================================


# 環境変数 AWS_ACCESS_KEY_ID と AWS_SECRET_ACCESS_KEY が参照される
provider "aws" {
    region = "ap-northeast-1"
}

#=============================================================================
#   VPC, Subnet
#=============================================================================
resource "aws_vpc" "aoyama-tf-vpc" {
    cidr_block           = "10.6.0.0/16"
    instance_tenancy     = "default"
    enable_dns_support   = true
    enable_dns_hostnames = true
    tags {
        Name = "aoyama-tf-vpc"
    }
}

resource "aws_subnet" "public_web" {
    vpc_id                  = "${aws_vpc.aoyama-tf-vpc.id}"
    cidr_block              = "10.6.1.0/24"
    availability_zone       = "ap-northeast-1a"
    map_public_ip_on_launch = true
    tags {
        Name = "aoyama-tf-vpc-public1"
    }
}

resource "aws_subnet" "private_db1" {
    vpc_id            = "${aws_vpc.aoyama-tf-vpc.id}"
    cidr_block        = "10.6.3.0/24"
    availability_zone = "ap-northeast-1a"
    tags {
        Name = "aoyama-tf-vpc-private1"
    }
}

resource "aws_subnet" "private_db2" {
    vpc_id            = "${aws_vpc.aoyama-tf-vpc.id}"
    cidr_block        = "10.6.4.0/24"
    availability_zone = "ap-northeast-1c"
    tags {
        Name = "aoyama-tf-vpc-private2"
    }
}

# 
resource "aws_internet_gateway" "gw" {
    vpc_id = "${aws_vpc.aoyama-tf-vpc.id}"
    tags {
        Name = "tf-gw"
    }
}

resource "aws_route_table" "public_rtb" {
    vpc_id = "${aws_vpc.aoyama-tf-vpc.id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.gw.id}"
    }
    tags {
        Name = "tf_rtb"
    }
}

resource "aws_route_table_association" "public_a" {
    subnet_id      = "${aws_subnet.public_web.id}"
    route_table_id = "${aws_route_table.public_rtb.id}"
}

#=============================================================================
#   セキュリティグループ app
#=============================================================================
resource "aws_security_group" "app" {
    name        = "tf_web"
    description = "It is a security group on http of aoyama-tf-vpc"
    vpc_id      = "${aws_vpc.aoyama-tf-vpc.id}"
    tags {
        Name = "tf_web"
    }
}

# sshを許可
resource "aws_security_group_rule" "ssh" {
    type              = "ingress"
    from_port         = 22
    to_port           = 22
    protocol          = "tcp"
    cidr_blocks       = ["0.0.0.0/0"]
    security_group_id = "${aws_security_group.app.id}"
}

# httpを許可
resource "aws_security_group_rule" "web" {
    type              = "ingress"
    from_port         = 80
    to_port           = 80
    protocol          = "tcp"
    cidr_blocks       = ["0.0.0.0/0"]
    security_group_id = "${aws_security_group.app.id}"
}

# Outboundを明示的に作成しないといけない
resource "aws_security_group_rule" "all" {
    type              = "egress"
    from_port         = 0
    to_port           = 65535
    protocol          = "tcp"
    cidr_blocks       = ["0.0.0.0/0"]
    security_group_id = "${aws_security_group.app.id}"
}

#=============================================================================
#   セキュリティグループ db
#=============================================================================
resource "aws_security_group" "db" {
    name        = "db_server"
    description = "It is a security group on db of aoyama-tf-vpc."
    vpc_id      = "${aws_vpc.aoyama-tf-vpc.id}"
    tags {
        Name = "tf_db"
    }
}

resource "aws_security_group_rule" "db" {
    type                     = "ingress"
    from_port                = 3306
    to_port                  = 3306
    protocol                 = "tcp"
    source_security_group_id = "${aws_security_group.app.id}"
    security_group_id        = "${aws_security_group.db.id}"
}

#=============================================================================
#   DBサブネットグループ
#=============================================================================
resource "aws_db_subnet_group" "main" {
    name        = "tf_dbsubnet"
    description = "It is a DB subnet group on aoyama-tf-vpc."
    subnet_ids  = ["${aws_subnet.private_db1.id}", "${aws_subnet.private_db2.id}"]
    tags {
        Name = "tf_dbsubnet"
    }
}
