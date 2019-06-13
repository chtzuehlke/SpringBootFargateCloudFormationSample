#!/bin/bash

PREFIX=${1:-default}
STACK_PREFIX="helloworld-$PREFIX"

SOURCE_PREFIX=${2:-default}
SOURCE_STACK_PREFIX="helloworld-$SOURCE_PREFIX"
REMOTE_TAG=$(./get-stack-output.sh $SOURCE_STACK_PREFIX-ecs DockerImage)

DB_PASSWORD_PARAM_NAME=$STACK_PREFIX-db-pwd

aws cloudformation update-stack --capabilities CAPABILITY_IAM --stack-name $STACK_PREFIX-ecs --template-body file://cloudformation/fargate.yaml --parameters \
	ParameterKey=NetworkStack,ParameterValue=$STACK_PREFIX-sg \
	ParameterKey=LoadBalancerStack,ParameterValue=$STACK_PREFIX-alb \
	ParameterKey=DatabaseStack,ParameterValue=$STACK_PREFIX-rds \
	ParameterKey=DockerImage,ParameterValue=$REMOTE_TAG \
	ParameterKey=DBPassSSMName,ParameterValue=$DB_PASSWORD_PARAM_NAME
