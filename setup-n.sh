#!/bin/bash
#FIXME error- and retry logic - until then, execute this step-by-step

PREFIX=${1:-default}
STACK_PREFIX="helloworld-$PREFIX"

SOURCE_PREFIX=${2:-default}

echo Environment: $PREFIX based on $SOURCE_PREFIX

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

echo Wait for Load Balancer Stack
aws cloudformation wait stack-create-complete --stack-name $STACK_PREFIX-alb

echo Wait for Database Stack
aws cloudformation wait stack-create-complete --stack-name $STACK_PREFIX-rds

echo Create Fargate Stack 
./create-stack-fargate-n.sh $PREFIX $SOURCE_PREFIX

echo Wait for Fargate Stack
aws cloudformation wait stack-create-complete --stack-name $STACK_PREFIX-ecs

echo Done
