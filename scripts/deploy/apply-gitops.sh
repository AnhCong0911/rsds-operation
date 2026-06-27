#!/usr/bin/env bash
set -euo pipefail
ENV="${1:-dev}"
kubectl apply -k "gitops/overlays/$ENV"
