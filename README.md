# rsds-operation

Infrastructure, platform, and GitOps repository for the RSDS enterprise platform.

## Scope

- **Terraform**: AWS VPC, EKS, RDS, S3, IAM, DNS, observability
- **Helm**: Platform components and shared library charts
- **GitOps**: Argo CD applications and Kustomize overlays
- **Operations**: Monitoring, logging, security, backup, DR runbooks

## Quick Start

```bash
# Validate Terraform (dev)
cd terraform/environments/dev
terraform init -backend=false && terraform validate

# Build GitOps overlay
kustomize build gitops/overlays/dev

# Lint Helm charts
find helm -name Chart.yaml -exec dirname {} \; | xargs -I{} helm lint {}
```

## Related Repositories

- [rsds-frontend](../rsds-frontend)
- [rsds-backend](../rsds-backend)
