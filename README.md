# rsds-operation

Infrastructure, platform, and GitOps repository for the RSDS enterprise platform.

## Scope

- **Terraform**: AWS VPC, EKS, RDS, S3, IAM, DNS, observability
- **Helm**: Platform components and shared library charts
- **GitOps**: Argo CD applications and Kustomize overlays
- **Operations**: Monitoring, logging, security, backup, DR runbooks
- **AI Workflows**: Deterministic DevOps automation (workflows, skills, rules)

## AI Workflow System

Structured workflows for AI-assisted platform operations:

| Component | Path | Description |
|-----------|------|-------------|
| Workflows | [`workflows/`](./workflows/) | End-to-end execution pipelines |
| Skills | [`skills/`](./skills/) | Reusable step instructions |
| Rules | [`rules/`](./rules/) | Global standards inherited by workflows |
| Cursor skill | [`.cursor/skills/helm-chart-generator/`](./.cursor/skills/helm-chart-generator/) | Cursor entry point |

**Available workflow:** [`helm-chart-generator`](./workflows/helm-chart-generator.md) — generate or update Helm charts from application source code.

Example prompt in Cursor:

> Generate a Helm chart for the notification-service in rsds-backend

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
