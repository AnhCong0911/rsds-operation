# AI Workflows

Deterministic, step-driven workflows for RSDS platform operations. Each workflow orchestrates reusable skills in `../skills/` and inherits global rules from `../rules/`.

## Available Workflows

| Workflow | File | Purpose |
|----------|------|---------|
| Helm Chart Generator | [helm-chart-generator.md](./helm-chart-generator.md) | Generate or update Helm charts from application source |

## Planned Workflows

| Workflow | Purpose |
|----------|---------|
| terraform-infrastructure-generator | Add AWS infrastructure via Terraform |
| github-actions-generator | Create or update CI/CD pipelines |
| eks-cluster-generator | EKS cluster operations |
| incident-investigation | Structured incident response |

## Usage

### In Cursor

The `helm-chart-generator` workflow is registered as a project skill at `.cursor/skills/helm-chart-generator/`. Ask Cursor:

> Generate a Helm chart for `user-service` in rsds-backend

### Manually

1. Read the workflow file
2. Execute each phase using the referenced skill in `skills/`
3. Follow global rules in `rules/`
4. End with PR — never deploy directly

## Design Principles

- **Analyze → Design → Implement → Validate → PR → Human approval**
- Reuse skills across workflows (Jira, PR description, validation)
- Global rules live in `rules/` — workflows reference, not duplicate
- AI never applies changes to production
