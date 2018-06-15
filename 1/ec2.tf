# 変数定義
variable "aws_key_name" {}

resource "aws_instance" "web" {
    ami                         = "ami-28ddc154"  # 東京リージョンにある Amazon Linux AMI の ID を指定する
    instance_type               = "t2.micro"
    key_name                    = "${var.aws_key_name}"  # EC2 に登録済の Key Pairs を指定する
    vpc_security_group_ids      = ["${aws_security_group.ec2_sg.id}"]
    subnet_id                   = "${aws_subnet.subnet_public1.id}"
    associate_public_ip_address = "true"
    root_block_device = {
        volume_type = "gp2"
        volume_size = "8"
    }
    tags {
        Name = "${var.system_name}"
    }
}
