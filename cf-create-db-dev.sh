#!/bin/bash

SG_ID=$(./cf-stack-output.sh samplewebworkload-net-dev DatabaseSG)

DEFAULT_VPC_ID=$(aws ec2 describe-vpcs --query 'Vpcs[?IsDefault==`true`].VpcId' --output text)
SUBNET_IDS=$(aws ec2 describe-subnets --query "Subnets[?VpcId==\`$DEFAULT_VPC_ID\`].SubnetId" --output text | sed 's/[[:space:]]/,/g')

aws cloudformation create-stack --stack-name samplewebworkload-db-dev --template-body file://db-cf.yaml --parameters \
  ParameterKey=Subnets,ParameterValue=\"$SUBNET_IDS\" \
  ParameterKey=VPC,ParameterValue=$DEFAULT_VPC_ID \
  ParameterKey=SecurityGroup,ParameterValue=$SG_ID
