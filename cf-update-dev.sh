#!/bin/bash

DEFAULT_VPC_ID=$(aws ec2 describe-vpcs --query 'Vpcs[?IsDefault==`true`].VpcId' --output text)
SUBNET_IDS=$(aws ec2 describe-subnets --query "Subnets[?VpcId==\`$DEFAULT_VPC_ID\`].SubnetId" --output text | sed 's/[[:space:]]/,/g')

aws cloudformation update-stack --capabilities CAPABILITY_IAM --stack-name samplewebworkload-dev --template-body file://ecr-cf.yaml --parameters \
  ParameterKey=Subnets,ParameterValue=\"$SUBNET_IDS\" \
  ParameterKey=VPC,ParameterValue=$DEFAULT_VPC_ID
