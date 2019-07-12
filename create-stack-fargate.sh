#!/bin/bash

PREFIX=${1:-default}
STACK_PREFIX="helloworld-$PREFIX"
VERSION=$2
REMOTE_TAG=$(./get-stack-output.sh $STACK_PREFIX-ecr DockerRepoUrl):$VERSION

DB_PASSWORD_PARAM_NAME=$STACK_PREFIX-db-pwd

aws cloudformation create-stack --capabilities CAPABILITY_IAM --stack-name $STACK_PREFIX-ecs --template-body file://cloudformation/fargate.yaml --parameters \
	ParameterKey=NetworkStack,ParameterValue=$STACK_PREFIX-sg \
	ParameterKey=LoadBalancerStack,ParameterValue=$STACK_PREFIX-alb \
	ParameterKey=DatabaseStack,ParameterValue=$STACK_PREFIX-rds \
	ParameterKey=DockerImage,ParameterValue=$REMOTE_TAG \
	ParameterKey=DBPassSSMName,ParameterValue=$DB_PASSWORD_PARAM_NAME

#FIXME to avoid terminate issue after pipeline deployment:
#- use --role-arn to create fargate stack (and create service role)
#- https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/cfn-console-add-tags.html
#- https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/using-iam-servicerole.html
#- https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/using-iam-template.html
#- https://docs.aws.amazon.com/de_de/codepipeline/latest/userguide/reference-pipeline-structure.html
#- https://docs.aws.amazon.com/de_de/AWSCloudFormation/latest/UserGuide/continuous-delivery-codepipeline-action-reference.html
