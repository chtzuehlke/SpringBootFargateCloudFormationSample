#!/bin/bash
aws cloudformation create-stack --capabilities CAPABILITY_IAM --stack-name samplewebworkload-dev --template-body file://ecr-cf.yaml
