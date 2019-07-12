#!/bin/bash

PREFIX=${1:-default}
STACK_PREFIX="helloworld-$PREFIX"

aws s3 rm --recursive s3://$(./get-stack-output.sh $STACK_PREFIX-pipe CodeBuildCacheBucket)/
aws s3 rm --recursive s3://$(./get-stack-output.sh $STACK_PREFIX-pipe PipelineArtifsctStoreBucket)/

aws cloudformation delete-stack --stack-name $STACK_PREFIX-pipe
aws cloudformation wait stack-delete-complete --stack-name $STACK_PREFIX-pipe
