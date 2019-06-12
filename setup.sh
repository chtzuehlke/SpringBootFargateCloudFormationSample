#!/bin/bash
#FIXME error- and retry logic - until then, execute this step-by-step

PREFIX=${1:-default}
STACK_PREFIX="helloworld-$PREFIX"

echo Environment: $PREFIX

echo Create Security Groups Stack
./create-stack-securitygroups.sh $PREFIX

echo Wait for Security Groups Stack
aws cloudformation wait stack-create-complete --stack-name $STACK_PREFIX-sg

DB_PASSWORD_PARAM_NAME=$STACK_PREFIX-db-pwd
echo Create Database Password in SSM: $DB_PASSWORD_PARAM_NAME
./genetare-random-ssm-parameterstore-securestring.sh $DB_PASSWORD_PARAM_NAME

echo Create Database Stack
./create-stack-database.sh $PREFIX

echo Create Load Balancer Stack
./create-stack-applicationloadbalancer.sh $PREFIX

echo Create Docker Registry Stack
./create-stack-ecr.sh $PREFIX

echo Build Spring Boot Java Application and Docker Image
./mvn-clean-install-dockerbuild.sh

echo Wait for Docker Registry Stack
aws cloudformation wait stack-create-complete --stack-name $STACK_PREFIX-ecr

echo Push Image to Docker Registry
./docker-tag-and-push.sh $PREFIX

echo Wait for Load Balancer Stack
aws cloudformation wait stack-create-complete --stack-name $STACK_PREFIX-alb

echo Wait for Database Stack
aws cloudformation wait stack-create-complete --stack-name $STACK_PREFIX-rds

echo Create Fargate Stack
./create-stack-fargate.sh $PREFIX

echo Wait Create Fargate Stack
aws cloudformation wait stack-create-complete --stack-name $STACK_PREFIX-ecs

echo Done
