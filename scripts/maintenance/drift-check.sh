#!/usr/bin/env bash
set -euo pipefail
ENV="${1:-dev}"
cd "terraform/environments/$ENV"
terraform plan -detailed-exitcode -var-file=terraform.tfvars
