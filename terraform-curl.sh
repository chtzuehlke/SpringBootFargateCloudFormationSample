#!/bin/bash

curl $(cd terraform && terraform output LoadBalancer)
