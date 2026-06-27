#!/usr/bin/env bash
set -euo pipefail
# Bootstrap S3 bucket and DynamoDB table for Terraform remote state
echo "Create S3 bucket rsds-terraform-state and DynamoDB table rsds-terraform-locks"
