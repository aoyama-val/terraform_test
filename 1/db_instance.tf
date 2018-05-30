resource "aws_db_instance" "db" {
    identifier              = "tf-dbinstance"
    allocated_storage       = 20
    engine                  = "postgres"
    engine_version          = "9.6.6"
    instance_class          = "db.t2.micro"
    storage_type            = "gp2"
    username                = "${var.aws_db_username}"
    password                = "${var.aws_db_password}"
    backup_retention_period = 1
    vpc_security_group_ids  = ["${aws_security_group.db.id}"]
    db_subnet_group_name    = "${aws_db_subnet_group.main.name}"
    multi_az                = false
    availability_zone       = "ap-northeast-1a"
}
