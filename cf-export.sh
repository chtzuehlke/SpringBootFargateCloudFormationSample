#!/bin/bash
aws cloudformation list-exports --query "Exports[?Name=='$1'].[Value]" --output text

