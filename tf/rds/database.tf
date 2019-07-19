provider "aws" {
  version = "~> 2.0"
  region  = "eu-central-1"
}

variable "vpc_id" {
  type = string
}

variable "db_security_group" {
  type = string
}

variable "db_masteruser_password" {
  type = string
}

data "aws_subnet_ids" "vps_subnets" {
  vpc_id = "${var.vpc_id}"
}

resource "aws_db_subnet_group" "DBSubnetGroup" {
  name       = "tfdbsubnetgroup"
  subnet_ids = "${data.aws_subnet_ids.vps_subnets.ids}"
}

resource "aws_db_instance" "DB" {
  allocated_storage    = 5
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  name                 = "db"
  username             = "masteruser"
  password             = var.db_masteruser_password
  parameter_group_name = "default.mysql5.7"
  db_subnet_group_name = "${aws_db_subnet_group.DBSubnetGroup.name}"
  vpc_security_group_ids = ["${var.db_security_group}"]
}

output "DBAddress" {
  value = aws_db_instance.DB.address
}

output "DBPort" {
  value = aws_db_instance.DB.port
}
