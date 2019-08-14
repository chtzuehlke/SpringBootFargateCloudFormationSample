#!/bin/bash
#FIXME error- and retry logic - until then, execute this step-by-step

PREFIX=${1:-dev}
STACK_PREFIX="helloworld-$PREFIX"

echo Environment: $PREFIX

#IMAGES=$(aws ecr list-images --repository-name $(./get-stack-output.sh $STACK_PREFIX-ecr DockerRepo) --query 'imageIds[*]' --output json)
#aws ecr batch-delete-image --repository-name $(./get-stack-output.sh $STACK_PREFIX-ecr DockerRepo) --image-ids "$IMAGES"

aws cloudformation delete-stack --stack-name $STACK_PREFIX-ecs

aws cloudformation wait stack-delete-complete --stack-name $STACK_PREFIX-ecs

aws cloudformation delete-stack --stack-name $STACK_PREFIX-alb
aws cloudformation delete-stack --stack-name $STACK_PREFIX-rds
#aws cloudformation delete-stack --stack-name $STACK_PREFIX-ecr

aws cloudformation wait stack-delete-complete --stack-name $STACK_PREFIX-alb
aws cloudformation wait stack-delete-complete --stack-name $STACK_PREFIX-rds

aws cloudformation delete-stack --stack-name $STACK_PREFIX-sg

#aws cloudformation wait stack-delete-complete --stack-name $STACK_PREFIX-ecr
aws cloudformation wait stack-delete-complete --stack-name $STACK_PREFIX-sg
