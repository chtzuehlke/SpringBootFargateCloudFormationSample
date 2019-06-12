#!/bin/bash

PREFIX=${1:-default}
STACK_PREFIX="helloworld-$PREFIX"

aws cloudformation create-stack --stack-name $STACK_PREFIX-ecr --template-body file://cloudformation/ecr.yaml
