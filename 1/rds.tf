variable "aws_db_username" {}
variable "aws_db_password" {}

resource "aws_db_instance" "db" {
    identifier              = "${var.system_name}-db"
    allocated_storage       = 20
    engine                  = "postgres"
    engine_version          = "9.6.6"
    instance_class          = "db.t2.micro"
    storage_type            = "gp2"
    username                = "${var.aws_db_username}"
    password                = "${var.aws_db_password}"
    backup_retention_period = 1
    vpc_security_group_ids  = ["${aws_security_group.rds_sg.id}"]
    db_subnet_group_name    = "${aws_db_subnet_group.db_subnet_group.name}"
    multi_az                = false
    availability_zone       = "ap-northeast-1a"
}
