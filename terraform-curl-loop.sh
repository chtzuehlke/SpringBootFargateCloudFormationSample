#!/bin/bash

URL=$(cd terraform/fargateservice && terraform output LoadBalancer)

while true
do
  curl $URL
  echo
  sleep 1
done
