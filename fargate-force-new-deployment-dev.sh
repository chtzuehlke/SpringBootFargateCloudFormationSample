#!/bin/bash

CLUSTER=$(./cf-stack-output.sh samplewebworkload-fargatew-dev FargateCluster)
SERVICE=$(./cf-stack-output.sh samplewebworkload-fargatew-dev FargateService)

aws ecs update-service --cluster $CLUSTER --service $SERVICE --force-new-deployment

