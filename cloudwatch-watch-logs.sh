#!/bin/bash
#pre-cond: pip install awslogs

PREFIX=${1:-default}
STACK_PREFIX="helloworld-$PREFIX"

awslogs get /ecs/$STACK_PREFIX-ecs --watch 
