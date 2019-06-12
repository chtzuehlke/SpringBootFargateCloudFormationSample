#!/bin/bash

PREFIX=${1:-default}
STACK_PREFIX="helloworld-$PREFIX"

DB_PASSWORD_PARAM_NAME=$STACK_PREFIX-db-pwd

aws cloudformation create-stack --capabilities CAPABILITY_IAM --stack-name $STACK_PREFIX-ecs --template-body file://cloudformation/fargate.yaml --parameters \
	ParameterKey=NetworkStack,ParameterValue=$STACK_PREFIX-sg \
	ParameterKey=LoadBalancerStack,ParameterValue=$STACK_PREFIX-alb \
	ParameterKey=DatabaseStack,ParameterValue=$STACK_PREFIX-rds \
	ParameterKey=DockerRepoStack,ParameterValue=$STACK_PREFIX-ecr \
	ParameterKey=DBPassSSMName,ParameterValue=$DB_PASSWORD_PARAM_NAME
