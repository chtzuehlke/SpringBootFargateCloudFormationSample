#!/bin/bash
DEFAULT_VPC_ID=$(aws ec2 describe-vpcs --query 'Vpcs[?IsDefault==`true`].VpcId' --output text)
SECURITY_GROUP=$(cd ../sg/ && terraform output DatabaseSG)
DB_PASSWORD="kl3felsfdkj!!_x355"

terraform destroy -var="vpc_id=$DEFAULT_VPC_ID" -var="db_security_group=$SECURITY_GROUP" -var="db_masteruser_password=$DB_PASSWORD"
