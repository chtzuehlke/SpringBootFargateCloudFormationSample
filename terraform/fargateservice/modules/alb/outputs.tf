output "LoadBalancer" {
  value = aws_lb.LoadBalancer.dns_name
}

output "TargetGroup" {
  value = aws_lb_target_group.TargetGroup.arn
}
