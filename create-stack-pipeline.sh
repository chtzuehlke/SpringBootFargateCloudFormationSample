#!/bin/bash

PREFIX=${1:-default}
STACK_PREFIX="helloworld-$PREFIX"

LOCAL_TAG=chtzuehlke/sample-web-workload:latest
REPO_URL=$(./get-stack-output.sh $STACK_PREFIX-ecr DockerRepoUrl)

CODECOMMIT_ARN=$(./get-stack-output.sh $STACK_PREFIX-git CodeCommitRepositoryARN)
CODECOMMIT_NAME=$(./get-stack-output.sh $STACK_PREFIX-git CodeCommitRepositoryName)

DB_PASSWORD_PARAM_NAME=$STACK_PREFIX-db-pwd

CLOUD_FORMATION_ROLE=$(./get-stack-output.sh $STACK_PREFIX-sg CloudFormationRole)

aws cloudformation create-stack --capabilities CAPABILITY_IAM --stack-name $STACK_PREFIX-pipe --template-body file://cloudformation/pipeline.yaml --parameters \
	ParameterKey=CodeCommitRepositoryARN,ParameterValue=$CODECOMMIT_ARN \
	ParameterKey=CodeCommitRepositoryName,ParameterValue=$CODECOMMIT_NAME \
	ParameterKey=DockerLocalTag,ParameterValue=$LOCAL_TAG \
	ParameterKey=RepoUrl,ParameterValue=$REPO_URL \
	ParameterKey=FargateStackName,ParameterValue=$STACK_PREFIX-ecs \
	ParameterKey=NetworkStack,ParameterValue=$STACK_PREFIX-sg \
	ParameterKey=LoadBalancerStack,ParameterValue=$STACK_PREFIX-alb \
	ParameterKey=DatabaseStack,ParameterValue=$STACK_PREFIX-rds \
	ParameterKey=DBPassSSMName,ParameterValue=$DB_PASSWORD_PARAM_NAME \
	ParameterKey=CloudFormationRole,ParameterValue=$CLOUD_FORMATION_ROLE
