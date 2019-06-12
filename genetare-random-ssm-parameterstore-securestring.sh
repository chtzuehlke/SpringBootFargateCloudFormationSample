#!/bin/bash

PARAM_NAME=$1

RANDOM_STRING=$(openssl rand -hex 20)

aws ssm put-parameter --overwrite --name $PARAM_NAME --type SecureString --value "$RANDOM_STRING"
