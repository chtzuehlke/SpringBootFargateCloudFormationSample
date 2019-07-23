#!/bin/bash

. ./ecr-login.sh

LOCAL_TAG=chtzuehlke/sample-web-workload:latest

REMOTE_TAG=$(cd terraform && terraform output DockerRepoUrl):version1
docker tag $LOCAL_TAG $REMOTE_TAG
docker push $REMOTE_TAG
