variable "db_port" {
  type = string
}

variable "db_address" {
  type = string
}

variable "db_pass_ssmname" {
  type = string
}

variable "docker_image" {
  type = string
}

variable "aws_lb_target_group_arn" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "ecs_security_group" {
  type = string
}
