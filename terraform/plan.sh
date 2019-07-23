#!/bin/bash

DEFAULT_VPC_ID=$(aws ec2 describe-vpcs --query 'Vpcs[?IsDefault==`true`].VpcId' --output text)

#FIXME random password
DB_PASSWORD="kl3felsfdkj!!_x355"

DOCKER_IMAGE_VERSION=version1

## FIXME below
SSM_DB_PASS_KEY="TFSampleRDSPass"
#aws ssm put-parameter --overwrite --name $SSM_DB_PASS_KEY --type SecureString --value 'kl3felsfdkj!!_x355'
## FIXME above

terraform plan \
    -var="vpc_id=$DEFAULT_VPC_ID" \
    -var="db_masteruser_password=$DB_PASSWORD" \
    -var="docker_image_version=$DOCKER_IMAGE_VERSION" \
    -var="db_pass_ssmname=$SSM_DB_PASS_KEY"
