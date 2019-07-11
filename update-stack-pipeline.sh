#!/bin/bash

PREFIX=${1:-default}
STACK_PREFIX="helloworld-$PREFIX"

DB_PASSWORD_PARAM_NAME=$STACK_PREFIX-db-pwd

aws cloudformation update-stack --capabilities CAPABILITY_IAM --stack-name $STACK_PREFIX-pipe --template-body file://cloudformation/pipeline.yaml --parameters \
	ParameterKey=CodeCommitRepositoryARN,UsePreviousValue=true \
	ParameterKey=CodeCommitRepositoryName,UsePreviousValue=true \
	ParameterKey=DockerLocalTag,UsePreviousValue=true \
	ParameterKey=RepoUrl,UsePreviousValue=true \
	ParameterKey=FargateStackName,ParameterValue=$STACK_PREFIX-ecs \
	ParameterKey=NetworkStack,ParameterValue=$STACK_PREFIX-sg \
	ParameterKey=LoadBalancerStack,ParameterValue=$STACK_PREFIX-alb \
	ParameterKey=DatabaseStack,ParameterValue=$STACK_PREFIX-rds \
	ParameterKey=DBPassSSMName,ParameterValue=$DB_PASSWORD_PARAM_NAME
