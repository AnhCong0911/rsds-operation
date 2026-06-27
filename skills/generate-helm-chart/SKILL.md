---
name: generate-helm-chart
description: Generate or update Helm chart files including Chart.yaml, values.yaml, values.schema.json, templates, and helpers following RSDS conventions and approved design.
---

# Generate Helm Chart

## Purpose

Implement approved Helm design as production-ready chart files.

## When to Use

- After design approval and Jira task creation
- Before `helm-validate`

## Prerequisites

- Approved design proposal
- Application analysis and deployment requirements docs
- Target repository checked out

## Steps

1. **Scaffold or open chart directory**
   - New: create full structure per `rules/helm-chart.md` section 3
   - Update: modify only files listed in design proposal

2. **Write Chart.yaml**
   - `name`, `description`, `type: application`, SemVer `version`, `appVersion`
   - Add `rsds-common` dependency if designed

3. **Write values.yaml**
   - Defaults from deployment requirements
   - Comments on non-obvious keys
   - No secrets, no environment-specific URLs

4. **Write values.schema.json**
   - JSON Schema matching values structure
   - Mark required fields

5. **Write _helpers.tpl**
   - `name`, `fullname`, `labels`, `selectorLabels`
   - Include rsds-common labels where dependency exists

6. **Write templates**
   - `deployment.yaml` — image, ports, probes, resources, securityContext
   - `service.yaml` — ClusterIP, port mapping
   - `serviceaccount.yaml`
   - `ingress.yaml` — if HTTP exposed (disabled by default)
   - `hpa.yaml` — if autoscaling designed
   - `pdb.yaml` — if HA designed

7. **Align with application source**
   - Container port = analyzed port
   - Probe paths = analyzed health endpoints
   - Env vars from analysis (as values keys)

8. **Update GitOps overlays** (in rsds-operation if applicable)
   - Add base kustomization entry
   - Create dev overlay values patch

9. **Update documentation**
   - Service/app README deploy section
   - CHANGELOG entry for chart

## RSDS Template Patterns

**Deployment probe pattern (Go services):**

```yaml
livenessProbe:
  httpGet:
    path: /health
    port: {{ .Values.service.targetPort }}
readinessProbe:
  httpGet:
    path: /health
    port: {{ .Values.service.targetPort }}
```

**Image reference pattern:**

```yaml
image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
```

## Expected Outputs

- Modified/created files under chart path
- List of files changed
- Brief implementation notes vs design

## Rules Reference

Follow `rules/helm-chart.md` sections 3–8, 13–15. Never deploy; only commit to feature branch for PR.
