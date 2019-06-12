#!/bin/bash

EXPORT_NAME=$1

aws cloudformation list-exports --query "Exports[?Name=='$EXPORT_NAME'].[Value]" --output text
