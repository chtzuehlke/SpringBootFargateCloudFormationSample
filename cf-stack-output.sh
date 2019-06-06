#!/bin/bash
aws cloudformation describe-stacks --stack-name $1 --query "Stacks[0].Outputs[?OutputKey=='$2'].OutputValue" --output text
