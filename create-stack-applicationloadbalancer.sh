#!/bin/bash

PREFIX=${1:-default}
STACK_PREFIX="helloworld-$PREFIX"

SSL_CERT_ARN=${2:-NONE}

aws cloudformation create-stack --stack-name $STACK_PREFIX-alb --template-body file://cloudformation/applicationloadbalancer.yaml --parameters \
	ParameterKey=NetworkStack,ParameterValue=$STACK_PREFIX-sg \
	ParameterKey=CertificateArn,ParameterValue="$SSL_CERT_ARN"
