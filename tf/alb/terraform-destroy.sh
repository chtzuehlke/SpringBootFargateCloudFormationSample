#!/bin/bash
DEFAULT_VPC_ID=$(aws ec2 describe-vpcs --query 'Vpcs[?IsDefault==`true`].VpcId' --output text)
SECURITY_GROUP=$(cd ../sg/ && terraform output LoadBalancerSG)

terraform destroy -var="vpc_id=$DEFAULT_VPC_ID" -var="alb_security_group=$SECURITY_GROUP"
