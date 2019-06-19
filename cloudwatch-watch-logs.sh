#!/bin/bash

PREFIX=${1:-default}
STACK_PREFIX="helloworld-$PREFIX"

docker run -v ~/.aws:/root/.aws --rm -i chtzdc/awslogs:latest get /ecs/$STACK_PREFIX-ecs --watch 
