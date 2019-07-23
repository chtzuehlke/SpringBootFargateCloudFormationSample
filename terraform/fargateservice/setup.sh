#!/bin/bash

ENVIRONMENT=$1
VERSION=$2

terraform init
terraform workspace new $ENVIRONMENT

./apply.sh $VERSION
