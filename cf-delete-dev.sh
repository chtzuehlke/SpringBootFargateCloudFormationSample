#!/bin/bash
aws ecr batch-delete-image --repository-name $(./cf-stack-output.sh samplewebworkload-dev DockerRepo) --image-ids imageTag=latest
aws cloudformation delete-stack --stack-name samplewebworkload-dev

