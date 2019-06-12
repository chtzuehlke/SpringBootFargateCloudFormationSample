#!/bin/bash

PREFIX=${1:-default}
STACK_PREFIX="helloworld-$PREFIX"

HOST=$(./get-stack-output.sh $STACK_PREFIX-alb LoadBalancer)

while true
do
  curl  http://$HOST/
  echo
  sleep 1
done
