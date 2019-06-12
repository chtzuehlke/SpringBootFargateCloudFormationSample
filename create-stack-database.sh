#!/bin/bash

PREFIX=${1:-default}
STACK_PREFIX="helloworld-$PREFIX"

DB_PASSWORD_PARAM_NAME=$STACK_PREFIX-db-pwd
DB_PASSWORD=$(./get-ssm-parameterstore-securestring.sh $DB_PASSWORD_PARAM_NAME)

aws cloudformation create-stack --stack-name $STACK_PREFIX-rds --template-body file://cloudformation/database.yaml --parameters \
	ParameterKey=NetworkStack,ParameterValue=$STACK_PREFIX-sg \
	ParameterKey=MasterUserPassword,ParameterValue=$DB_PASSWORD
