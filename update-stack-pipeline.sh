#!/bin/bash

PREFIX=${1:-default}
STACK_PREFIX="helloworld-$PREFIX"

LOCAL_TAG=chtzuehlke/sample-web-workload:latest
REPO_URL=$(./get-stack-output.sh $STACK_PREFIX-ecr DockerRepoUrl)

CODECOMMIT_ARN=$(./get-stack-output.sh $STACK_PREFIX-git CodeCommitRepositoryARN)
CODECOMMIT_NAME=$(./get-stack-output.sh $STACK_PREFIX-git CodeCommitRepositoryName)

CONTAINER_NAME=$STACK_PREFIX-ecs

FARGATE_CLUSTER=$(./get-stack-output.sh $STACK_PREFIX-ecs FargateCluster)
FARGATE_SERVICE=$(./get-stack-output.sh $STACK_PREFIX-ecs FargateService)

aws cloudformation update-stack --capabilities CAPABILITY_IAM --stack-name $STACK_PREFIX-pipe --template-body file://cloudformation/pipeline.yaml --parameters \
	ParameterKey=CodeCommitRepositoryARN,UsePreviousValue=true \
	ParameterKey=CodeCommitRepositoryName,UsePreviousValue=true \
	ParameterKey=DockerLocalTag,UsePreviousValue=true \
	ParameterKey=RepoUrl,UsePreviousValue=true \
	ParameterKey=ContainerName,UsePreviousValue=true \
	ParameterKey=FargateCluster,UsePreviousValue=true \
	ParameterKey=FargateService,UsePreviousValue=true
