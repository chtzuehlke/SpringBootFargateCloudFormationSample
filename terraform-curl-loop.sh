#!/bin/bash

while true
do
  curl $(cd terraform && terraform output LoadBalancer)
  echo
  sleep 1
done
