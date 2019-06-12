#!/bin/bash

PREFIX=${1:-default}
STACK_PREFIX="helloworld-$PREFIX"

DEFAULT_VPC_ID=$(aws ec2 describe-vpcs --query 'Vpcs[?IsDefault==`true`].VpcId' --output text)
SUBNET_IDS=$(aws ec2 describe-subnets --query "Subnets[?VpcId==\`$DEFAULT_VPC_ID\`].SubnetId" --output text | sed 's/[[:space:]]/,/g')

aws cloudformation create-stack --stack-name $STACK_PREFIX-sg --template-body file://cloudformation/securitygroups.yaml --parameters \
	ParameterKey=VPC,ParameterValue=$DEFAULT_VPC_ID \
	ParameterKey=Subnets,ParameterValue=\"$SUBNET_IDS\"
