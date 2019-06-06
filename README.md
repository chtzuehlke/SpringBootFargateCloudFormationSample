# Sample: Spring Boot & Fargate & CLoudFormation

## Pre-Conditions

- AWS cli (installed, configured: sufficient IAM permissions)
- Bash (tested with macOS terminal)

## Setup Development Environment (approx. 60 USD/Month)

Under the hoods

- Create new private docker registry (new CloudFormation stack via AWS cli)
- Create docker image (maven & docker)
- Upload docker image (AWS cli & docker)
- Create new elastic load balancer (new CloudFormation stack via AWS cli)
- Create new fargate service with 1 running task (new CloudFormation stack via AWS cli)

Steps

    ./setup-dev.sh && ./curl-loop-dev.sh

## Update Development Environment

Under the hoods

- Create docker image (maven & docker)
- Upload docker image (AWS cli & docker)
- Force new fargate task deployment (AWS cli)

Steps

    ./update-dev.sh

## Teardown Development Environment

Under the hoods

- Remove docker images from docker regisry (AWS cli)
- Create private docker registry (delete CloudFormation stack via AWS cli)
- Create elastic load balancer (delete CloudFormation stack via AWS cli)
- Create fargate service (delete CloudFormation stack via AWS cli)

Steps

    ./teardown-dev.sh

## FIXMEs

- AWS CodeDeploy for Blue/Green deployment (as soon as this is supported for ECS by CloudFormation)
- Security (-group) improvement: access to service only via load balancer
- Load balancer: HTTPS listener
- Add RDS to sample
- ...
