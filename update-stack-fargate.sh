#!/bin/bash

PREFIX=${1:-default}
STACK_PREFIX="helloworld-$PREFIX"
VERSION=$2

DB_PASSWORD_PARAM_NAME=$STACK_PREFIX-db-pwd

REMOTE_TAG=$(./get-stack-output.sh $STACK_PREFIX-ecr DockerRepoUrl):$VERSION

aws cloudformation update-stack --capabilities CAPABILITY_IAM --stack-name $STACK_PREFIX-ecs --template-body file://cloudformation/fargate.yaml --parameters \
	ParameterKey=NetworkStack,ParameterValue=$STACK_PREFIX-sg \
	ParameterKey=LoadBalancerStack,ParameterValue=$STACK_PREFIX-alb \
	ParameterKey=DatabaseStack,ParameterValue=$STACK_PREFIX-rds \
	ParameterKey=DockerImage,ParameterValue=$REMOTE_TAG \
	ParameterKey=DBPassSSMName,ParameterValue=$DB_PASSWORD_PARAM_NAME
