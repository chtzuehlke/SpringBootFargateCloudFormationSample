#!/bin/bash

PREFIX=${1:-default}
STACK_PREFIX="helloworld-$PREFIX"

DB_PASSWORD_PARAM_NAME=$STACK_PREFIX-db-pwd

SOURCE_PREFIX=$2
SOURCE_STACK_PREFIX="helloworld-$SOURCE_PREFIX"
DOCKER_REPO_STACK=$SOURCE_STACK_PREFIX-ecr
DOCKER_IMAGE_TAG=${3:-latest}

aws cloudformation update-stack --capabilities CAPABILITY_IAM --stack-name $STACK_PREFIX-ecs --template-body file://cloudformation/fargate.yaml --parameters \
	ParameterKey=NetworkStack,ParameterValue=$STACK_PREFIX-sg \
	ParameterKey=LoadBalancerStack,ParameterValue=$STACK_PREFIX-alb \
	ParameterKey=DatabaseStack,ParameterValue=$STACK_PREFIX-rds \
	ParameterKey=DockerRepoStack,ParameterValue=$DOCKER_REPO_STACK \
	ParameterKey=DBPassSSMName,ParameterValue=$DB_PASSWORD_PARAM_NAME \
	ParameterKey=DockerImageTag,ParameterValue=$DOCKER_IMAGE_TAG
