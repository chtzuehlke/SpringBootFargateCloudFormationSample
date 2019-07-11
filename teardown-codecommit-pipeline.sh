#!/bin/bash

PREFIX=${1:-default}
STACK_PREFIX="helloworld-$PREFIX"

aws cloudformation delete-stack --stack-name $STACK_PREFIX-git
aws cloudformation wait stack-delete-complete --stack-name $STACK_PREFIX-git
