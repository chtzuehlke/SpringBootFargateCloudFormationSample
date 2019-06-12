#!/bin/bash

PREFIX=${1:-default}
STACK_PREFIX="helloworld-$PREFIX"

CLUSTER=$(./get-stack-output.sh $STACK_PREFIX-ecs FargateCluster)
SERVICE=$(./get-stack-output.sh $STACK_PREFIX-ecs FargateService)

aws ecs update-service --cluster $CLUSTER --service $SERVICE --force-new-deployment
