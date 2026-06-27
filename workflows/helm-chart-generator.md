---
name: helm-chart-generator
description: End-to-end workflow for generating or updating Helm charts from application source code and existing Helm repositories. Ensures design-first, validated, traceable chart delivery via Pull Request with human approval.
---

# Helm Chart Generator Workflow

Generate or update Helm charts for RSDS applications based on source code analysis and existing Helm repository conventions.

This workflow enforces:
- analyze-before-design
- design-before-implementation
- reuse of existing charts and library templates
- strict validation before PR
- traceability via Jira
- human approval gate — AI never deploys

**Global rules:** `rules/helm-chart.md`

---

# 0. Input

Input can be:
- Jira ticket describing new service or deployment need
- Application change (new port, env var, health endpoint)
- Feature request: "Add Helm chart for `<app>`"
- Slack/message: "Update chart for `<service>` after Dockerfile change"

**Required context:**
- Application repository (`rsds-frontend`, `rsds-backend`, or path to service)
- Application/service name
- Target environment scope (dev only vs all envs)

**Optional context:**
- Existing chart path (if known)
- Related GitOps overlay path

---

# 1. Analyze Application Source Code

## Skill: `read-application-source`

### Actions:
- Read Dockerfile, entrypoint, config files
- Extract ports, health endpoints, env vars
- Identify runtime dependencies (DB, cache, messaging)
- Document image naming from CI workflows

### Output:
- Application analysis document
- Open questions list

---

# 2. Understand Existing Helm Repository

## Skill: `read-helm-repository`

### Actions:
- Scan chart locations in app and operation repos
- Find existing chart for target app (if any)
- Identify `rsds-common` library and conventions
- Map GitOps overlay references

### Output:
- Helm repository analysis
- Reuse recommendation (extend vs create new)

---

# 3. Analyze Deployment Requirements

## Skill: `analyze-deployment-requirements`

### Actions:
- Classify workload type (API, frontend, worker)
- Define scaling, ingress, secrets strategy
- Split chart values vs GitOps overlay values
- Flag rollout and migration risks

### Output:
- Deployment requirements specification

---

# 4. Design Helm Chart Changes

## Skill: `helm-design-proposal`

### Actions:
- Decide create vs update, chart path, version bump
- Design templates, values, schema, dependencies
- Plan GitOps overlay updates
- Assess upgrade impact

### Output:
- Design proposal document
- **Approval gate:** human must approve before step 6 for new charts or major changes

---

# 5. Create or Update Jira Task

## Skill: `create-jira-task`

### Actions:
- Create Epic/Story/Task with acceptance criteria
- Link design proposal
- Break down: chart generation, GitOps update, validation, PR

### Output:
- Jira ticket key(s) for traceability

---

# 6. Generate or Update Helm Chart

## Skill: `generate-helm-chart`

### Actions:
- Implement approved design in chart directory
- Write Chart.yaml, values.yaml, values.schema.json, templates
- Update GitOps overlays in rsds-operation (if applicable)
- Update service README and CHANGELOG

### Output:
- Chart files on feature branch
- Implementation notes

---

# 7. Validate Helm Chart

## Skill: `helm-validate`

### Actions:
- `helm dependency update`
- `helm lint`
- `helm template` (default + overlay values)
- Naming, dependency, security, upgrade compatibility review

### Output:
- Validation report with PASS/FAIL verdict
- **Blocked if FAIL** — return to step 6

---

# 8. Generate Deployment Verification Checklist

## Skill: `generate-deployment-checklist`

### Actions:
- Dev/staging/prod verification steps
- Rollback procedure
- Links to runbooks

### Output:
- Deployment verification checklist

---

# 9. Generate Pull Request

## Skill: `generate-pr-description`

### Actions:
- Summarize changes, rationale, validation results
- Document upgrade impact and risks
- Include verification steps and reviewer checklist
- Open PR on feature branch (human merges)

### Output:
- GitHub PR description (ready to paste or auto-fill)
- Feature branch with chart changes

---

# 10. Human Review and Approval

## Manual Step

- Review PR against `rules/helm-chart.md`
- Run local validation if desired
- Verify Jira linkage
- Approve or request changes
- Merge triggers CI (`helm-lint-all.yml`, `gitops-validate.yml`)
- GitOps promotion to dev/staging/prod is a **separate manual/approved process**

---

# Workflow Rules

This workflow MUST follow global rules from:
- `rules/helm-chart.md`

Additional workflow constraints:

## 1. Analyze Before Designing
Never propose chart structure without application source analysis.

## 2. Design Before Implementation
No chart file generation before design approval (new charts and major changes).

## 3. Reuse First
Always prefer existing charts and `helm/library/rsds-common` over duplicated templates.

## 4. Never Assume Application Behavior
Ports, probes, and env vars must come from source analysis — not defaults.

## 5. Validation Required
No PR without passing `helm-validate` skill output.

## 6. Traceability
Every change MUST link to a Jira ticket.

## 7. Human Final Control
AI NEVER deploys, applies, or merges to production. PR + human approval only.

## 8. Environment Separation
Chart defaults are env-agnostic; prod/staging specifics live in GitOps overlays.

---

# Output of Workflow

Final deliverables:

| Deliverable | Location |
|-------------|----------|
| Application analysis | Workflow output / PR |
| Helm repo analysis | Workflow output / PR |
| Deployment requirements | Workflow output / PR |
| Design proposal | Workflow output / PR |
| Jira ticket | External (Jira) |
| Helm chart files | App repo or rsds-operation |
| GitOps overlay updates | rsds-operation/gitops/ |
| Validation report | PR description |
| Deployment checklist | PR description |
| Pull Request | GitHub |

---

# Execution Flow

```text
Request
  ↓
Analyze Application Source        (read-application-source)
  ↓
Understand Helm Repository        (read-helm-repository)
  ↓
Analyze Deployment Requirements   (analyze-deployment-requirements)
  ↓
Design Helm Chart Changes         (helm-design-proposal)
  ↓
Human Design Approval             [gate]
  ↓
Create Jira Task                  (create-jira-task)
  ↓
Generate / Update Helm Chart      (generate-helm-chart)
  ↓
Validate Helm Chart               (helm-validate)
  ↓
Generate Deployment Checklist     (generate-deployment-checklist)
  ↓
Generate Pull Request             (generate-pr-description)
  ↓
Human Review and Approval         [gate]
```

---

# Related Repositories

| Repo | Role in workflow |
|------|------------------|
| rsds-frontend | Source + `deploy/helm/rsds-frontend/` |
| rsds-backend | Source + `deploy/helm/services/<svc>/` |
| rsds-operation | Library charts, GitOps overlays, this workflow |

---

# End of Workflow
