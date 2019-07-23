#!/bin/bash

VERSION=$1

LOCAL_TAG=chtzuehlke/sample-web-workload:latest
REMOTE_TAG=$(cat terraform/dockerregistry/repo_url.txt):$VERSION

. ./ecr-login.sh
docker tag $LOCAL_TAG $REMOTE_TAG
docker push $REMOTE_TAG
