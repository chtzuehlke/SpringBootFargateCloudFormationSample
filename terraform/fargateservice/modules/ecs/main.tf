data "aws_subnet_ids" "vps_subnets" {
  vpc_id = "${var.vpc_id}"
}

data "aws_iam_policy_document" "ECSExecutionRole-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ECSExecutionRole" {
  name               = "${terraform.workspace}-ECSExecutionRole"
  path               = "/service-role/"
  assume_role_policy = "${data.aws_iam_policy_document.ECSExecutionRole-policy.json}"
}

data "aws_iam_policy" "AmazonECSTaskExecutionRolePolicy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ECSExecutionRole-attach" {
  role       = "${aws_iam_role.ECSExecutionRole.name}"
  policy_arn = "${data.aws_iam_policy.AmazonECSTaskExecutionRolePolicy.arn}"
}

### FIXME avoid * resource
resource "aws_iam_role" "TaskRole" {
  name               = "${terraform.workspace}-TaskRole"
  path               = "/service-role/"
  assume_role_policy = "${data.aws_iam_policy_document.ECSExecutionRole-policy.json}"
}

resource "aws_iam_policy" "TaskRole-policy" {
  name        = "${terraform.workspace}-test-policy"
  description = "A test policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ssm:GetParameter"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "TaskRole-attach" {
  role       = "${aws_iam_role.TaskRole.name}"
  policy_arn = "${aws_iam_policy.TaskRole-policy.arn}"
}

resource "aws_ecs_cluster" "FargateCluster" {
  name = "${terraform.workspace}-FargateCluster"
}

resource "aws_ecs_service" "FargateService" {
  name            = "${terraform.workspace}-FargateService"
  cluster         = "${aws_ecs_cluster.FargateCluster.id}"
  task_definition = "${aws_ecs_task_definition.TaskDefinition.arn}"
  desired_count   = 1
  depends_on      = ["aws_iam_role_policy_attachment.ECSExecutionRole-attach"]

  launch_type = "FARGATE"
  deployment_maximum_percent = "200"
  deployment_minimum_healthy_percent = "100"

  network_configuration {
    security_groups    = ["${var.ecs_security_group}"]
    subnets            = "${data.aws_subnet_ids.vps_subnets.ids}"
    assign_public_ip   = true
  } 

  load_balancer {
    target_group_arn = "${var.aws_lb_target_group_arn}"
    container_name   = "SpringBootContainer"
    container_port   = 8080
  }
}

resource "aws_ecs_task_definition" "TaskDefinition" {
  family                    = "${terraform.workspace}-SpringBootDemo"
  task_role_arn             = "${aws_iam_role.TaskRole.arn}"
  execution_role_arn        = "${aws_iam_role.ECSExecutionRole.arn}"
  network_mode              = "awsvpc"
  requires_compatibilities  = ["FARGATE"]
  cpu                       = "1024"
  memory                    = "2048"
  container_definitions     = <<DEFINITION
[
  {
    "cpu": 1024,
    "environment": [{
      "name": "SPRING_PROFILES_ACTIVE",
      "value": "aws"
    },{
      "name": "DBPort",
      "value": "${var.db_port}"
    },{
      "name": "DBAddress",
      "value": "${var.db_address}"
    },{
      "name": "DBPassSSMName",
      "value": "${var.db_pass_ssmname}"
    }],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/fargate/service/${terraform.workspace}-fargatelog",
        "awslogs-region": "eu-central-1",
        "awslogs-stream-prefix": "ecs"
      }
    },
    "essential": true,
    "image": "${var.docker_image}",
    "memory": 2048,
    "name": "SpringBootContainer",
    "portMappings": [
      {
        "containerPort": 8080
      }
    ]
  }
]
DEFINITION  
}

resource "aws_cloudwatch_log_group" "logs" {
  name              = "/fargate/service/${terraform.workspace}-fargatelog"
  retention_in_days = "1"
}
