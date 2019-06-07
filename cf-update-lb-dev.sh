#!/bin/bash

SG_ID=$(./cf-stack-output.sh samplewebworkload-net-dev LoadBalancerSG)

DEFAULT_VPC_ID=$(aws ec2 describe-vpcs --query 'Vpcs[?IsDefault==`true`].VpcId' --output text)
SUBNET_IDS=$(aws ec2 describe-subnets --query "Subnets[?VpcId==\`$DEFAULT_VPC_ID\`].SubnetId" --output text | sed 's/[[:space:]]/,/g')

aws cloudformation update-stack --stack-name samplewebworkload-lb-dev --template-body file://lb-cf.yaml --parameters \
  ParameterKey=Subnets,ParameterValue=\"$SUBNET_IDS\" \
  ParameterKey=VPC,ParameterValue=$DEFAULT_VPC_ID \
  ParameterKey=SecurityGroup,ParameterValue=$SG_ID \
  ParameterKey=CertificateArn,ParameterValue='arn:aws:acm:eu-west-1:208464084183:certificate/73d7cb1d-3137-4182-86c5-c01a7578e595'
