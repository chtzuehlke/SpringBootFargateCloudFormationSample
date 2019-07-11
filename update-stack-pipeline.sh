#!/bin/bash

PREFIX=${1:-default}
STACK_PREFIX="helloworld-$PREFIX"

LOCAL_TAG=chtzuehlke/sample-web-workload:latest
REPO_URL=$(./get-stack-output.sh $STACK_PREFIX-ecr DockerRepoUrl)

CODECOMMIT_ARN=$(./get-stack-output.sh $STACK_PREFIX-git CodeCommitRepositoryARN)
CODECOMMIT_NAME=$(./get-stack-output.sh $STACK_PREFIX-git CodeCommitRepositoryName)

aws cloudformation update-stack --capabilities CAPABILITY_IAM --stack-name $STACK_PREFIX-pipe --template-body file://cloudformation/pipeline.yaml --parameters \
	ParameterKey=CodeCommitRepositoryARN,ParameterValue=$CODECOMMIT_ARN \
	ParameterKey=CodeCommitRepositoryName,ParameterValue=$CODECOMMIT_NAME \
	ParameterKey=DockerLocalTag,ParameterValue=$LOCAL_TAG \
	ParameterKey=RepoUrl,ParameterValue=$REPO_URL
