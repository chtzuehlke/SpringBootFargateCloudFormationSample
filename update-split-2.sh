#!/bin/bash
#FIXME error- and retry logic - until then, execute this step-by-step

PREFIX=${1:-dev}
STACK_PREFIX="helloworld-$PREFIX"

VERSION=${2:-version1}

echo Environment: $PREFIX
echo "$(date) Start $PREFIX:$VERSION" >> split2.log

#echo Build Spring Boot Java Application and Docker Image
#./mvn-clean-install-dockerbuild.sh

#VERSION=$(./mvn-project-version.sh)-$(date '+%Y%m%d%H%M%S')
 
# echo Push Image $VERSION to Docker Registry
#./docker-tag-and-push.sh $PREFIX $VERSION

echo Update Fargate Stack $VERSION
./update-stack-fargate.sh $PREFIX $VERSION 

aws cloudformation wait stack-update-complete --stack-name $STACK_PREFIX-ecs

echo "$(date) End   $PREFIX:$VERSION" >> split2.log
