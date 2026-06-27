---
name: analyze-deployment-requirements
description: Synthesize application analysis and Helm repository context into concrete Kubernetes deployment requirements including scaling, ingress, secrets, and environment strategy.
---

# Analyze Deployment Requirements

## Purpose

Translate application facts and platform conventions into a deployment requirements spec for chart design.

## When to Use

- After `read-application-source` and `read-helm-repository`
- Before `helm-design-proposal`

## Steps

1. **Classify workload type**
   - Stateless HTTP API, SPA/SSR frontend, worker/consumer, cron job

2. **Define scaling requirements**
   - Min/max replicas per environment (dev: 1, staging: 2, prod: 2+)
   - HPA metrics: CPU, memory, custom (RPS, queue depth)
   - PDB requirement (prod services with HA)

3. **Define networking**
   - ClusterIP port mapping (service port → container port)
   - Ingress: host pattern, TLS, path prefix
   - NetworkPolicy needs

4. **Define configuration strategy**
   - ConfigMap vs Secret split
   - Env vars from values vs External Secrets
   - Which values live in chart vs GitOps overlay

5. **Define storage**
   - PersistentVolume needs (usually none for stateless apps)
   - emptyDir for temp/cache

6. **Define service account and RBAC**
   - Dedicated ServiceAccount per chart
   - IRSA / workload identity annotations (document for GitOps)

7. **Define rollout strategy**
   - Rolling update defaults
   - PreStop hooks, graceful shutdown timeout

8. **Flag risks and dependencies**
   - Database migrations (init container vs Job)
   - Breaking port or probe changes

## Expected Outputs

```markdown
## Deployment Requirements: <app-name>

### Workload
- Type:
- Replicas: dev / staging / prod

### Networking
- Service: port → targetPort
- Ingress: yes/no, host pattern

### Probes
- Liveness / Readiness / Startup

### Configuration
| Key | Source | Chart vs GitOps |
|-----|--------|-----------------|

### Scaling
- HPA: yes/no, metrics
- PDB: yes/no

### Security
- ServiceAccount:
- Non-root:
- Secret refs:

### Risks
-
```

## Rules Reference

Follow `rules/helm-chart.md` sections 9–11 (K8s best practices, Security, Environment Separation).
