#!/bin/bash
aws cloudformation update-stack --stack-name samplewebworkload-dev --template-body file://ecr-cf.yaml
