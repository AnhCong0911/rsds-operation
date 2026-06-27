---
name: helm-chart-generator
description: End-to-end workflow for generating or updating Helm charts from application source code. Orchestrates analysis, design, Jira, chart generation, validation, and PR creation. Use when creating or updating Helm charts for RSDS applications.
---

# Helm Chart Generator Workflow

Execute the full workflow defined in `workflows/helm-chart-generator.md`.

## Quick Start

When the user asks to create or update a Helm chart:

1. Read `rules/helm-chart.md` — all steps inherit these rules
2. Execute workflow phases in order (do not skip validation or design gates)
3. Use skills from `skills/` — one skill per phase
4. Never deploy to any cluster; end with PR description for human review

## Workflow File

Full orchestration: [`workflows/helm-chart-generator.md`](../../workflows/helm-chart-generator.md)

## Skill Map

| Phase | Skill |
|-------|-------|
| Analyze application | `skills/read-application-source/` |
| Analyze Helm repo | `skills/read-helm-repository/` |
| Deployment requirements | `skills/analyze-deployment-requirements/` |
| Design proposal | `skills/helm-design-proposal/` |
| Jira task | `skills/create-jira-task/` |
| Generate chart | `skills/generate-helm-chart/` |
| Validate | `skills/helm-validate/` |
| Deployment checklist | `skills/generate-deployment-checklist/` |
| PR description | `skills/generate-pr-description/` |

## Hard Constraints

- Design before implementation (new charts and major changes)
- Reuse existing charts and `rsds-common` library first
- Human approval required before merge
- AI never deploys or applies to production

## RSDS Chart Paths

- Frontend: `../rsds-frontend/deploy/helm/rsds-frontend/`
- Backend services: `../rsds-backend/deploy/helm/services/<service>/`
- Library: `helm/library/rsds-common/`
- GitOps overlays: `gitops/overlays/{dev,staging,prod}/`
