---
name: generate-deployment-checklist
description: Generate a post-merge deployment verification checklist for Helm chart changes including smoke tests, rollout observation, and rollback steps.
---

# Generate Deployment Checklist

## Purpose

Give operators and reviewers concrete steps to verify chart changes after merge and before/after promotion to prod.

## When to Use

- After `helm-validate` passes
- Included in PR description and runbooks

## Steps

1. **Define pre-deploy checks**
   - Argo CD / GitOps sync status
   - Image tag/digest available in registry
   - Chart version published to OCI (if applicable)

2. **Define dev verification**
   - Sync GitOps dev overlay
   - Pod status: `kubectl get pods -l app.kubernetes.io/name=<app>`
   - Logs: no crash loop
   - Health endpoint: curl from port-forward or ingress
   - Service port connectivity

3. **Define staging verification**
   - Repeat dev checks on staging overlay
   - Integration test or smoke script: `scripts/verify/smoke-test.sh`
   - HPA behavior (if enabled): observe scaling under load

4. **Define prod promotion checks**
   - PDB allows voluntary disruption
   - Rolling update completes without downtime
   - Metrics/alerts normal post-deploy

5. **Define rollback procedure**
   - Revert GitOps commit or pin previous image digest
   - Argo CD rollback command
   - Expected recovery time

6. **Link to runbooks**
   - Reference `docs/runbooks.md`, `docs/troubleshooting.md`

## Expected Outputs

```markdown
## Deployment Verification Checklist: <app-name>

### Pre-Deploy
- [ ] Chart lint/template passed in CI
- [ ] Image available: `ghcr.io/rsds/<app>:<tag>`
- [ ] Jira ticket linked: RSDS-XXX

### Dev
- [ ] GitOps dev overlay synced
- [ ] Pods Running: `kubectl get pods -n rsds-dev -l app.kubernetes.io/name=<app>`
- [ ] Health check: `curl -sf http://localhost:<port>/health`
- [ ] Logs clean: `kubectl logs -l app.kubernetes.io/name=<app> --tail=50`

### Staging
- [ ] Overlay synced
- [ ] Smoke test passed
- [ ] Ingress reachable (if applicable)

### Prod Promotion
- [ ] Change window approved
- [ ] PDB verified
- [ ] Rollout observed — 0 unavailable during rolling update
- [ ] Dashboards green (link)

### Rollback
1. Revert GitOps PR / pin previous digest
2. `argocd app rollback <app> <revision>`
3. Verify pods on previous version

### Sign-off
- Dev: ___
- Staging: ___
- Prod: ___
```

## Rules Reference

Follow `rules/helm-chart.md` sections 16–18.
