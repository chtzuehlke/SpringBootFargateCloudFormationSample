#!/bin/bash
DOCKER_REPO_URL=$(./cf-stack-output.sh DockerRepoUrl)
docker tag chtzuehlke/sample-web-workload:latest $DOCKER_REPO_URL:latest
docker push $DOCKER_REPO_URL:latest

