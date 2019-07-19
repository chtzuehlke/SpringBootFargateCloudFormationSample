#!/bin/bash
curl $(cd tf/alb/ && terraform output LoadBalancer)

