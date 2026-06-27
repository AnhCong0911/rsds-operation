---
name: generate-pr-description
description: Generate a structured GitHub Pull Request description with summary, rationale, validation results, risks, and verification steps. Reusable across DevOps workflows.
---

# Generate PR Description

## Purpose

Produce reviewer-ready PR descriptions that meet RSDS quality standards.

## When to Use

- After validation passes
- Final step before opening PR (human submits/merges)

## Steps

1. **Gather inputs**
   - Jira ticket key and link
   - Design proposal summary
   - List of changed files
   - Validation report
   - Deployment checklist
   - Upgrade impact assessment

2. **Write Summary**
   - 1–3 sentences: what changed and for which app/chart

3. **Write Why**
   - Business/technical reason
   - Link Jira: `Closes RSDS-XXX` or `Related to RSDS-XXX`

4. **Document chart changes**
   - Files added/modified/deleted
   - Version bump (Chart.yaml)

5. **Document Kubernetes resource changes**
   - New/changed kinds (Deployment, HPA, Ingress, etc.)

6. **Include validation summary**
   - Paste helm lint/template results
   - CI status placeholders

7. **Document upgrade impact**
   - Breaking vs non-breaking
   - Required GitOps overlay updates
   - Required app config changes

8. **List risks**
   - Downtime, probe failures, resource pressure, dependency issues

9. **Provide verification steps**
   - Copy from deployment checklist (dev-focused for PR review)

10. **Add reviewer checklist**

## Expected Outputs

Use this PR template:

```markdown
## Summary
<!-- 1-3 sentences -->

## Why
<!-- rationale + Jira link -->

Closes RSDS-XXX

## Helm Chart Changes
| File | Change |
|------|--------|

**Chart version:** x.y.z → x.y.z

## Kubernetes Resource Changes
- <!-- e.g. Added HPA, updated probe path -->

## Validation Results
- [ ] `helm dependency update` — PASS
- [ ] `helm lint` — PASS
- [ ] `helm template` — PASS
- [ ] Security review — PASS

## Upgrade Impact
- **Breaking:** yes/no
- **Notes:**

## Risks
-

## Verification Steps
1. ...
2. ...

## Reviewer Checklist
- [ ] Chart follows `rules/helm-chart.md`
- [ ] No secrets in values or templates
- [ ] Probes match application health endpoints
- [ ] GitOps overlay updated (if needed)
- [ ] Jira linked
```

## Rules Reference

Follow `rules/helm-chart.md` section 18 (Pull Request Quality).
