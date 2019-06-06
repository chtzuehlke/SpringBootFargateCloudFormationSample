#!/bin/bash
. ./ecr-login.sh

LOCAL_TAG=chtzuehlke/sample-web-workload:latest
REMOTE_TAG=$(./cf-stack-output.sh samplewebworkload-repo-dev DockerRepoUrl):latest

echo Pushing $LOCAL_TAG to $REMOTE_TAG

docker tag $LOCAL_TAG $REMOTE_TAG
docker push $REMOTE_TAG
