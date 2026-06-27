#!/usr/bin/env bash
set -euo pipefail
kubectl get nodes
kubectl get pods -A --field-selector=status.phase!=Running,status.phase!=Succeeded
