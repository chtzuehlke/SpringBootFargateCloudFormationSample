#!/bin/bash
aws cloudformation create-stack --stack-name samplewebworkload-dev --template-body file://ecr-cf.yaml
