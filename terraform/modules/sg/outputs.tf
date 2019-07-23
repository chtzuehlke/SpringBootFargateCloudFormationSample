output "ApplicationSG" {
  value = aws_security_group.ApplicationSG.id
}

output "DatabaseSG" {
  value = aws_security_group.DatabaseSG.id
}

output "LoadBalancerSG" {
  value = aws_security_group.LoadBalancerSG.id
}
