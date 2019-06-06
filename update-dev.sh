#!/bin/bash
./mvn-docker-build.sh 
./docker-tag-push-dev.sh 
./fargate-force-new-deployment-dev.sh

