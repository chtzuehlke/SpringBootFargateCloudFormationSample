#!/bin/bash
PASS=$(openssl rand -hex 20)
aws ssm put-parameter --overwrite --name dev.db.rand.pass --type SecureString --value "$PASS"
