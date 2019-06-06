#!/bin/bash

aws cloudformation create-stack --stack-name samplewebworkload-repo-dev --template-body file://repo-cf.yaml
