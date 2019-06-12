#!/bin/bash
aws ssm get-parameter --name dev.db.rand.pass --with-decryption --query "Parameter.Value" --output text
