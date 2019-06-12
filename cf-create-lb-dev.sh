#!/bin/bash

#FIXME below: provide your Cert Manager cert to enable TLS
#SSL_CERT_ARN="arn:aws:acm:eu-west-1:208464084183:certificate/73d7cb1d-3137-4182-86c5-c01a7578e595"
SSL_CERT_ARN="NONE"

aws cloudformation create-stack --stack-name samplewebworkload-lb-dev --template-body file://lb-cf.yaml --parameters \
  ParameterKey=NetworkStack,ParameterValue=samplewebworkload-net-dev \
  ParameterKey=CertificateArn,ParameterValue="$SSL_CERT_ARN"
