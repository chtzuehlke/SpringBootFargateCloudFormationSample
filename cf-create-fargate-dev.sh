#!/bin/bash

DB_ID=$(./cf-stack-output.sh samplewebworkload-db-dev DBIdentifier)
DB_ADDR=$(./cf-stack-output.sh samplewebworkload-db-dev DBAddress)
DB_PORT=$(./cf-stack-output.sh samplewebworkload-db-dev DBPort)

SG_ID=$(./cf-stack-output.sh samplewebworkload-net-dev ApplicationSG)

ELB_TARGET_GROUP=$(./cf-stack-output.sh samplewebworkload-lb-dev TargetGroup)

DOCKER_REPO_NAME=$(./cf-stack-output.sh samplewebworkload-repo-dev DockerRepo)

DEFAULT_VPC_ID=$(aws ec2 describe-vpcs --query 'Vpcs[?IsDefault==`true`].VpcId' --output text)
SUBNET_IDS=$(aws ec2 describe-subnets --query "Subnets[?VpcId==\`$DEFAULT_VPC_ID\`].SubnetId" --output text | sed 's/[[:space:]]/,/g')

aws cloudformation create-stack --capabilities CAPABILITY_IAM --stack-name samplewebworkload-fargatew-dev --template-body file://fargate-cf.yaml --parameters \
  ParameterKey=Subnets,ParameterValue=\"$SUBNET_IDS\" \
  ParameterKey=VPC,ParameterValue=$DEFAULT_VPC_ID \
  ParameterKey=TargetGroup,ParameterValue=$ELB_TARGET_GROUP \
  ParameterKey=DockerRepo,ParameterValue=$DOCKER_REPO_NAME \
  ParameterKey=SecurityGroup,ParameterValue=$SG_ID \
  ParameterKey=DBIdentifier,ParameterValue=$DB_ID \
  ParameterKey=DBPort,ParameterValue=$DB_ADDR \
  ParameterKey=DBAddress,ParameterValue=$DB_PORT \
  ParameterKey=DBPassSSMName,ParameterValue="dev.db.rand.pass"
