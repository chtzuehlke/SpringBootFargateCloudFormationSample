#!/bin/bash

while true
do
  curl $(cd terraform/fargateservice && terraform output LoadBalancer)
  echo
  sleep 1
done
