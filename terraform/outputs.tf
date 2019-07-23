output "DockerRepoUrl" {
  value = module.ecr.DockerRepoUrl
}

output "LoadBalancer" {
  value = module.alb.LoadBalancer
}
