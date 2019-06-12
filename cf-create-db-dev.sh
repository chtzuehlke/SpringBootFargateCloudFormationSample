#!/bin/bash

DB_PASSWORD=$(./ssm-get-dbpass.sh | jq -r ".Parameter.Value")

aws cloudformation create-stack --stack-name samplewebworkload-db-dev --template-body file://db-cf.yaml --parameters \
  ParameterKey=NetworkStack,ParameterValue=samplewebworkload-net-dev \
  ParameterKey=MasterUserPassword,ParameterValue=$DB_PASSWORD
