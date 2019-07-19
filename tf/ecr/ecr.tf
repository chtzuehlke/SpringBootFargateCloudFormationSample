provider "aws" {
  version = "~> 2.0"
  region  = "eu-central-1"
}

resource "aws_ecr_repository" "DockerRepo" {
  name = "tfdockerrepo"
}

output "DockerRepo" {
  value = aws_ecr_repository.DockerRepo.name
}

output "DockerRepoUrl" {
  value = aws_ecr_repository.DockerRepo.repository_url
}
