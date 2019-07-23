provider "aws" {
  version = "~> 2.0"
  region  = "eu-central-1"
}

module "ecr" {
  source = "./modules/ecr"
}

module "sg" {
  source = "./modules/sg"

  vpc_id = var.vpc_id
}

module "rds" {
  source = "./modules/rds"

  vpc_id = var.vpc_id
  
  db_security_group = module.sg.DatabaseSG

  db_masteruser_password = var.db_masteruser_password
}

module "alb" {
  source = "./modules/alb"

  vpc_id = var.vpc_id

  alb_security_group = module.sg.LoadBalancerSG
}

module "ecs" {
  source = "./modules/ecs"

  vpc_id = var.vpc_id

  ecs_security_group = module.sg.ApplicationSG

  db_port = module.rds.DBPort
  db_address = module.rds.DBAddress
  db_pass_ssmname = var.db_pass_ssmname

  docker_image = "${module.ecr.DockerRepoUrl}:${var.docker_image_version}"

  aws_lb_target_group_arn = module.alb.TargetGroup
}
