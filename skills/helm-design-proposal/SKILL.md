---
name: helm-design-proposal
description: Design Helm chart structure, template plan, values schema, and dependency strategy before any chart files are generated or modified.
---

# Helm Design Proposal

## Purpose

Produce an approved design before implementation. Enforces design-first workflow.

## When to Use

- New chart creation
- Major chart refactor (new resources, breaking value changes)
- Before `generate-helm-chart`

## Steps

1. **Review inputs**
   - Application analysis output
   - Helm repository analysis output
   - Deployment requirements output

2. **Decide chart scope**
   - New chart vs update existing
   - Chart name and path
   - Library chart dependency on `rsds-common`

3. **Design file structure**
   - List templates to create/modify/delete
   - Define `_helpers.tpl` functions

4. **Design values.yaml**
   - Top-level keys and defaults
   - Which values are overlay-only (document, don't default in chart)

5. **Design values.schema.json**
   - Required keys, types, enums

6. **Design GitOps integration**
   - Overlay paths in `rsds-operation/gitops/overlays/`
   - Image tag pinning strategy

7. **Assess upgrade impact**
   - Breaking vs non-breaking
   - Migration steps for existing deployments

8. **Obtain approval**
   - Present design to human reviewer
   - Do not proceed to code generation until approved (for new/major changes)

## Expected Outputs

```markdown
## Helm Design Proposal: <app-name>

### Decision
- Action: create | update
- Chart path:
- Chart version bump: patch | minor | major

### Templates
| File | Action | Purpose |
|------|--------|---------|

### Values Design
```yaml
# proposed top-level keys (skeleton)
```

### Dependencies
- rsds-common: yes/no, version

### GitOps
- Overlay updates needed:

### Upgrade Impact
- Breaking changes:
- Rollout notes:

### Approval
- [ ] Human approved to proceed
```

## Rules Reference

Follow all sections of `rules/helm-chart.md`. Hard constraint: no code before design approval for new/major work.
