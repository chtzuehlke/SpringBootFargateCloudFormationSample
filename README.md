# Sample: Spring Boot & Fargate & CloudFormation

## Disclaimer

- Not production ready (e.g. automation scripts w/o error handling)

## Pre-Conditions

- AWS cli (installed & configured: sufficient IAM permissions)
- Docker (running)
- Linux-like environment (bash, curl, ... - tested with macOS)

## Setup Development Environment (approx. 60 USD/Month)

Under the hoods

- Create new private docker registry (new CloudFormation stack via AWS cli)
- Create docker image (maven & docker)
- Upload docker image (AWS cli & docker)
- Create new elastic load balancer (new CloudFormation stack via AWS cli)
- Create new fargate service with 1 running task (new CloudFormation stack via AWS cli)

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

Steps

    ./teardown-dev.sh

## FIXMEs

- CI: Code Build
- CD: AWS CodeDeploy for Blue/Green deployment (as soon as this is supported for ECS by CloudFormation)
- Add RDS to sample
- ...
