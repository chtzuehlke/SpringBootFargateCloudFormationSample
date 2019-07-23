#!/bin/bash

terraform init
terraform workspace new dev
./apply.sh
terraform output DockerRepoUrl > repo_url.txt
