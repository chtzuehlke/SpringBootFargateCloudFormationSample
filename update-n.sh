#!/bin/bash
#FIXME error- and retry logic - until then, execute this step-by-step

PREFIX=${1:-default}
STACK_PREFIX="helloworld-$PREFIX"

SOURCE_PREFIX=${2:-default}

echo Environment: $PREFIX based on $SOURCE_PREFIX

echo Update Fargate Stack
./update-stack-fargate-n.sh $PREFIX $SOURCE_PREFIX 

aws cloudformation wait stack-update-complete --stack-name $STACK_PREFIX-ecs
