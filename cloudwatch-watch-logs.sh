#!/bin/bash

PREFIX=${1:-default}
STACK_PREFIX="helloworld-$PREFIX"

#pre-cond: pip install awslogs
alias awslogs='docker run -v ~/.aws:/root/.aws --rm -i chtzdc/awslogs:latest'

awslogs get /ecs/$STACK_PREFIX-ecs --watch 
