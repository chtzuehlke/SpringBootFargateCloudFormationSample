#!/bin/bash

ENVIRONMENT=$(terraform workspace show)
VERSION=$1

DEFAULT_VPC_ID=$(aws ec2 describe-vpcs --query 'Vpcs[?IsDefault==`true`].VpcId' --output text)

DOCKER_REPO_URL=$(cat ../dockerregistry/repo_url.txt)

DB_PASSWORD="fixMe234!x_sd342sDDs"
SSM_DB_PASS_KEY="$ENVIRONMENT-TFSampleRDSPass"
#aws ssm put-parameter --overwrite --name $SSM_DB_PASS_KEY --type SecureString --value "$DB_PASSWORD"

terraform plan \
    -var="vpc_id=$DEFAULT_VPC_ID" \
    -var="db_masteruser_password=$DB_PASSWORD" \
    -var="docker_image_version=$VERSION" \
    -var="db_pass_ssmname=$SSM_DB_PASS_KEY" \
    -var="docker_repo_url=$DOCKER_REPO_URL"
