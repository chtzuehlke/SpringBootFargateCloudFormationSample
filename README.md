# Sample: Spring Boot & Fargate & RDS & CloudFormation

## Disclaimer

- Not production ready (e.g. automation scripts w/o error handling)
- See also FIXMEs (below)

## Pre-Conditions

- AWS cli installed & configured (sufficient IAM permissions, default region)
- Default VPC present in default AWS region
- Docker running
- Linux-like environment (bash, curl, sed, ...) - tested with macOS
- openssl installed
- jq installed

## Setup Development Environment (approx. 75 USD/Month)

Under the hoods

- Create new Elastic Container Registry (new CloudFormation stack via AWS cli)
- Create docker image (maven & docker)
- Upload docker image (AWS cli & docker)
- Create Security Groups (new CloudFormation stack via AWS cli)
- Create new Elastic Load Balancer (new CloudFormation stack via AWS cli)
- Create new DB password parameter (random password) in SSM Parameter Store (AWS cli)
- Create new RDS MySQL DB instance (new CloudFormation stack via AWS cli)
- Create new Fargate Service with 1 running task with 1 container with DB access (new CloudFormation stack via AWS cli)

Steps

    ./setup-dev.sh

Verify

    ./curl-loop-dev.sh

## Application Deployment

Under the hoods

- Create new docker image (maven & docker)
- Upload new docker image (AWS cli & docker)
- Force new fargate task deployment (AWS cli)

Steps

    ./update-dev.sh

## Teardown Development Environment

Under the hoods

- Remove docker images from docker regisry (AWS cli)
- Delete private docker registry (delete CloudFormation stack via AWS cli)
- Delete elastic load balancer (delete CloudFormation stack via AWS cli)
- Delete fargate service (delete CloudFormation stack via AWS cli)
- Delete RDS instance w/o backup (delete CloudFormation stack via AWS cli)
- ...

Steps

    ./teardown-dev.sh

## FIXMEs

- Remove hard-coded certificate arn
- mysql access via TLS
