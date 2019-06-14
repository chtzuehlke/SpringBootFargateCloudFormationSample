#!/bin/bash

PREFIX=${1:-default}
STACK_PREFIX="helloworld-$PREFIX"

SOURCE_PREFIX=${2:-default}
SOURCE_STACK_PREFIX="helloworld-$SOURCE_PREFIX"
REMOTE_TAG=$(./get-stack-output.sh $SOURCE_STACK_PREFIX-ecs DockerImage)

aws cloudformation update-stack --capabilities CAPABILITY_IAM --stack-name $STACK_PREFIX-ecs --use-previous-template --parameters \
	ParameterKey=DockerImage,ParameterValue=$REMOTE_TAG \
	ParameterKey=NetworkStack,UsePreviousValue=true \
	ParameterKey=LoadBalancerStack,UsePreviousValue=true \
	ParameterKey=DatabaseStack,UsePreviousValue=true \
	ParameterKey=DBPassSSMName,UsePreviousValue=true
