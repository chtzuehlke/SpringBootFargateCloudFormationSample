#!/bin/bash

#FIXME error and retry logic, hehe

echo Create Load Balancer Stack
./cf-create-lb-dev.sh

echo Create Docker Registry Stack
./cf-create-repo-dev.sh

echo Build Spring Boot App and Docker Image
./mvn-docker-build.sh

echo Wait for Docker Registry Stack
aws cloudformation wait stack-create-complete --stack-name samplewebworkload-repo-dev

echo Push Image to Docker Registry
./docker-tag-push-dev.sh

echo Wait for Load Balancer Stack
aws cloudformation wait stack-create-complete --stack-name samplewebworkload-lb-dev

echo Create Fargate Stack
./cf-create-fargate-dev.sh

echo Wait Create Fargate Stack
aws cloudformation wait stack-create-complete --stack-name samplewebworkload-fargatew-dev

echo Done
