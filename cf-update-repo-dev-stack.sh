#!/bin/bash
aws cloudformation update-stack --capabilities CAPABILITY_IAM --stack-name samplewebworkload-dev --template-body file://ecr-cf.yaml
