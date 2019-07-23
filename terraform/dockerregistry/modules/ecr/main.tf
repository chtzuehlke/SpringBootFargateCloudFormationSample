resource "aws_ecr_repository" "DockerRepo" {
  name = "${terraform.workspace}-dockerrepo"
}
