# AI Skills

Reusable skills invoked by workflows in `../workflows/`. Each skill is a self-contained instruction set for a single capability.

## Skills Index

| Skill | Directory | Used By |
|-------|-----------|---------|
| Read Application Source | [read-application-source/](./read-application-source/) | helm-chart-generator |
| Read Helm Repository | [read-helm-repository/](./read-helm-repository/) | helm-chart-generator |
| Analyze Deployment Requirements | [analyze-deployment-requirements/](./analyze-deployment-requirements/) | helm-chart-generator |
| Helm Design Proposal | [helm-design-proposal/](./helm-design-proposal/) | helm-chart-generator |
| Create Jira Task | [create-jira-task/](./create-jira-task/) | helm-chart-generator, (future workflows) |
| Generate Helm Chart | [generate-helm-chart/](./generate-helm-chart/) | helm-chart-generator |
| Helm Validate | [helm-validate/](./helm-validate/) | helm-chart-generator |
| Generate Deployment Checklist | [generate-deployment-checklist/](./generate-deployment-checklist/) | helm-chart-generator |
| Generate PR Description | [generate-pr-description/](./generate-pr-description/) | helm-chart-generator, (future workflows) |

## Skill Format

Each skill directory contains `SKILL.md` with YAML frontmatter:

```yaml
---
name: skill-name
description: Brief description (< 1024 chars)
---
```

## Global Rules

Skills that touch Helm charts must follow [`../rules/helm-chart.md`](../rules/helm-chart.md).

## Cursor Integration

The helm-chart-generator workflow entry point: [`.cursor/skills/helm-chart-generator/`](../.cursor/skills/helm-chart-generator/)
