#!/bin/bash

DB_PASSWORD_PARAM_NAME="dev.db.rand.pass"

aws cloudformation create-stack --capabilities CAPABILITY_IAM --stack-name samplewebworkload-fargatew-dev --template-body file://fargate-cf.yaml --parameters \
  ParameterKey=NetworkStack,ParameterValue=samplewebworkload-net-dev \
  ParameterKey=LoadBalancerStack,ParameterValue=samplewebworkload-lb-dev \
  ParameterKey=DatabaseStack,ParameterValue=samplewebworkload-db-dev \
  ParameterKey=DockerRepoStack,ParameterValue=samplewebworkload-repo-dev \
  ParameterKey=DBPassSSMName,ParameterValue=$DB_PASSWORD_PARAM_NAME
