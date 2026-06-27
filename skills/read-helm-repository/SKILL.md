---
name: read-helm-repository
description: Scan existing Helm chart repositories to identify conventions, reusable charts, library dependencies, and chart locations before creating or updating charts.
---

# Read Helm Repository

## Purpose

Build a map of existing Helm assets and conventions so new charts align with the platform.

## When to Use

- Before creating a new chart
- Before updating an existing chart
- When deciding whether to extend vs create new

## Steps

1. **Locate chart directories**
   - Application repo: `deploy/helm/`, `charts/`, `helm/`
   - Operation repo: `helm/library/`, `helm/platform/`, `helm/umbrella/`
   - GitOps: `gitops/base/`, `gitops/overlays/`

2. **Check for existing chart for target app**
   - Search by app/service name
   - If exists: read `Chart.yaml`, `values.yaml`, all templates

3. **Identify library charts**
   - Read `helm/library/rsds-common/templates/_helpers.tpl`
   - Note dependency patterns in existing service charts

4. **Extract conventions**
   - Label keys and helper naming
   - Default `replicaCount`, resource sizes
   - Probe paths and port mapping patterns
   - Ingress annotation patterns

5. **Map GitOps integration**
   - Which overlays reference the chart
   - How image tags are pinned (digest vs semver)

6. **Identify reuse opportunities**
   - Can existing chart be extended?
   - Should template be promoted to library chart?

## Expected Outputs

```markdown
## Helm Repository Analysis

### Chart Locations
| App/Service | Chart Path | Version | GitOps Overlay |
|-------------|------------|---------|----------------|

### Library Charts
- rsds-common: (helpers available)

### Conventions
- Naming:
- Labels:
- Default resources:
- Probe pattern:

### Existing Chart for Target
- Exists: yes/no
- Path:
- Gaps vs application analysis:

### Reuse Recommendation
- (extend existing | create new | promote to library)
```

## Rules Reference

Follow `rules/helm-chart.md` sections 2 (Repository Analysis), 3 (Chart Structure), 13 (Reusable Templates).
