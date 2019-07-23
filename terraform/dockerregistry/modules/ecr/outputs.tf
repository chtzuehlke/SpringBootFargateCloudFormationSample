output "DockerRepo" {
  value = aws_ecr_repository.DockerRepo.name
}

output "DockerRepoUrl" {
  value = aws_ecr_repository.DockerRepo.repository_url
}
