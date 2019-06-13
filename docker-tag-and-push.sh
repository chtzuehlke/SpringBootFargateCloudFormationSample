#!/bin/bash

PREFIX=${1:-default}
STACK_PREFIX="helloworld-$PREFIX"
VERSION=$2

. ./ecr-login.sh

LOCAL_TAG=chtzuehlke/sample-web-workload:latest

REMOTE_TAG=$(./get-stack-output.sh $STACK_PREFIX-ecr DockerRepoUrl):latest
echo Pushing $LOCAL_TAG to $REMOTE_TAG
docker tag $LOCAL_TAG $REMOTE_TAG
docker push $REMOTE_TAG

REMOTE_TAG=$(./get-stack-output.sh $STACK_PREFIX-ecr DockerRepoUrl):$VERSION
echo Pushing $LOCAL_TAG to $REMOTE_TAG
docker tag $LOCAL_TAG $REMOTE_TAG
docker push $REMOTE_TAG
