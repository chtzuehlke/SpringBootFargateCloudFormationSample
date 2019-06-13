#!/bin/bash
#FIXME error- and retry logic - until then, execute this step-by-step

PREFIX=${1:-default}
STACK_PREFIX="helloworld-$PREFIX"

echo Environment: $PREFIX

aws cloudformation delete-stack --stack-name $STACK_PREFIX-ecs

aws cloudformation wait stack-delete-complete --stack-name $STACK_PREFIX-ecs

aws cloudformation delete-stack --stack-name $STACK_PREFIX-alb
aws cloudformation delete-stack --stack-name $STACK_PREFIX-rds

aws cloudformation wait stack-delete-complete --stack-name $STACK_PREFIX-alb
aws cloudformation wait stack-delete-complete --stack-name $STACK_PREFIX-rds

aws cloudformation delete-stack --stack-name $STACK_PREFIX-sg

aws cloudformation wait stack-delete-complete --stack-name $STACK_PREFIX-sg
