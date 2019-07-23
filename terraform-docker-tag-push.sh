#!/bin/bash

VERSION=$1

. ./ecr-login.sh

LOCAL_TAG=chtzuehlke/sample-web-workload:latest

REMOTE_TAG=$(cd terraform && terraform output DockerRepoUrl):$VERSION
docker tag $LOCAL_TAG $REMOTE_TAG
docker push $REMOTE_TAG
