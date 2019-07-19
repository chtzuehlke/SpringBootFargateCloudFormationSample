provider "aws" {
  version = "~> 2.0"
  region  = "eu-central-1"
}

variable "vpc_id" {
  type = string
}

variable "alb_security_group" {
  type = string
}

data "aws_subnet_ids" "vps_subnets" {
  vpc_id = "${var.vpc_id}"
}

resource "aws_lb_listener" "Listener" {
  load_balancer_arn = "${aws_lb.LoadBalancer.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.TargetGroup.arn}"
  }
}

resource "aws_lb" "LoadBalancer" {
  name               = "TFLoadBalancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${var.alb_security_group}"]
  subnets            = "${data.aws_subnet_ids.vps_subnets.ids}"
}

resource "aws_lb_target_group" "TargetGroup" {
  name     = "TFTargetGroup"
  port     = 8080
  protocol = "HTTP"
  target_type = "ip"
  vpc_id   = "${var.vpc_id}"

  health_check {
    path = "/"
    healthy_threshold = 2
    unhealthy_threshold = 4
    timeout = 5
    interval = 30
    matcher = "200"
  }
}

output "LoadBalancer" {
  value = aws_lb.LoadBalancer.dns_name
}

output "TargetGroup" {
  value = aws_lb_target_group.TargetGroup.arn
}
