#!/bin/bash
#FIXME error- and retry logic - until then, execute this step-by-step

PREFIX=${1:-default}
STACK_PREFIX="helloworld-$PREFIX"

echo Environment: $PREFIX

./mvn-clean-install-dockerbuild.sh 
./docker-tag-and-push.sh $PREFIX 
./fargate-force-new-deployment.sh $PREFIX 
