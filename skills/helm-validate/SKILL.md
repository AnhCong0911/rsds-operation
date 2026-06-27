---
name: helm-validate
description: Validate Helm charts using helm lint, helm template, values schema checks, naming review, dependency resolution, and security review before PR creation.
---

# Helm Validate

## Purpose

Catch errors before human review. Required gate — no PR without validation.

## When to Use

- After `generate-helm-chart`
- Before `generate-pr-description`

## Steps

1. **Resolve dependencies**

```bash
cd <chart-path>
helm dependency update
helm dependency list
```

2. **Lint chart**

```bash
helm lint <chart-path>
helm lint <chart-path> --values <chart-path>/values.yaml
```

3. **Render templates**

```bash
helm template test-release <chart-path> \
  --values <chart-path>/values.yaml \
  --debug > /tmp/rendered.yaml
```

4. **Render with GitOps overlay** (if exists)

```bash
helm template test-release <chart-path> \
  --values gitops/overlays/dev/<app>/values.yaml
```

5. **Validate values schema**

```bash
# If values.schema.json exists, validate sample values match schema
# Use helm lint with --strict where supported
```

6. **Kubernetes manifest review**
   - Check rendered YAML for:
     - Valid apiVersion/kind
     - Resource names ≤ 63 chars
     - Required labels present
     - Probes defined
     - Resources set
     - No hardcoded secrets

7. **Optional: kubeconform**

```bash
helm template test-release <chart-path> | kubeconform -summary -
```

8. **Naming consistency review**
   - Chart name matches directory and service name
   - Helpers use consistent prefix

9. **Dependency validation**
   - All Chart.yaml dependencies resolve
   - No circular dependencies

10. **Upgrade compatibility review**
    - Compare with previous chart version (if update)
    - Flag breaking value or resource renames

11. **Security review**
    - No secrets in rendered output
    - securityContext appropriate
    - No privileged containers unless justified

## Expected Outputs

```markdown
## Helm Validation Report: <chart-name>

### Commands Run
- helm dependency update: PASS/FAIL
- helm lint: PASS/FAIL
- helm template: PASS/FAIL
- kubeconform: PASS/FAIL/SKIPPED

### Issues
| Severity | File | Issue | Resolution |
|----------|------|-------|------------|

### Kubernetes Resources Rendered
- Deployment, Service, ...

### Security Notes
-

### Upgrade Compatibility
- Breaking: yes/no
- Notes:

### Verdict
- [ ] Ready for PR
- [ ] Blocked — fix issues above
```

## CI Integration

Validation mirrors `.github/workflows/helm-lint-all.yml` and `.github/actions/helm-lint`.

## Rules Reference

Follow `rules/helm-chart.md` section 16 (Validation).
