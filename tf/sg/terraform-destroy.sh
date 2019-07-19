#!/bin/bash
DEFAULT_VPC_ID=$(aws ec2 describe-vpcs --query 'Vpcs[?IsDefault==`true`].VpcId' --output text)
terraform destroy -var="vpc_id=$DEFAULT_VPC_ID"

