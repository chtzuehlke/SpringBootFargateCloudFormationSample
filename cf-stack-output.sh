#!/bin/bash
aws cloudformation describe-stacks --stack-name samplewebworkload-dev --query "Stacks[0].Outputs[?OutputKey=='$1'].OutputValue" --output text
