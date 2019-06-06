#!/bin/bash

HOST=$(./cf-stack-output.sh samplewebworkload-lb-dev LoadBalancer)

while true
do
  curl  http://$HOST/
  echo
  sleep 1
done

