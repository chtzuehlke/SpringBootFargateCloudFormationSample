#!/bin/bash

DEFAULT_VPC_ID=$(aws ec2 describe-vpcs --query 'Vpcs[?IsDefault==`true`].VpcId' --output text)

SECURITY_GROUP=$(cd ../sg/ && terraform output ApplicationSG)

ALB_ARN=$(cd ../alb && terraform output TargetGroup)

DOCKER_IMAGE="$(cd ../ecr && terraform output DockerRepoUrl):version1"

DB_ADDDR=$(cd ../rds && terraform output DBAddress)
DB_PORT=$(cd ../rds && terraform output DBPort)

## FIXME below
SSM_DB_PASS_KEY="TFSampleRDSPass"
#aws ssm put-parameter --overwrite --name $SSM_DB_PASS_KEY --type SecureString --value 'kl3felsfdkj!!_x355'
## FIXME above

terraform destroy -var="vpc_id=$DEFAULT_VPC_ID" -var="ecs_security_group=$SECURITY_GROUP" \
    -var="aws_lb_target_group_arn=$ALB_ARN" \
    -var="docker_image=$DOCKER_IMAGE" \
    -var="db_pass_ssmname=$SSM_DB_PASS_KEY" \
    -var="db_address=$DB_ADDDR" \
    -var="db_port=$DB_PORT"
