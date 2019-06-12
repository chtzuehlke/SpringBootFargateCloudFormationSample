#!/bin/bash

PARAM_NAME=$1

aws ssm get-parameter --name $PARAM_NAME --with-decryption --query "Parameter.Value" --output text
