---
name: helm-chart-generator
description: Complete, standalone Helm Chart Generator workflow with all 9 skills, global rules, and Cursor integration
version: 1.0
last-updated: 2026-06-28
---

# Helm Chart Generator Workflow — Complete Edition

**Single-file reference** for generating or updating Helm charts for RSDS applications.

- **Purpose:** End-to-end orchestration from application analysis → design → implementation → validation → PR
- **Audience:** Platform engineers, AI agents, chart reviewers
- **Scope:** RSDS frontend, backend microservices, and operation platform charts

---

## Quick Start

When asked to create or update a Helm chart:

1. **Input** — Jira ticket, application name, environment scope
2. **Run phases in order** — 0 through 10, executing each skill
3. **Enforce gates** — design approval before implementation; validation before PR
4. **Output** — GitHub PR with chart files, validation report, deployment checklist

**Cursor integration:** Invoke skill `helm-chart-generator` in Cursor.

---

## 0. Input

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

## 1. Analyze Application Source Code

### Skill: `read-application-source`

**Purpose:** Extract deployment-relevant facts from application source code before designing a Helm chart.

#### When to Use
- New application needs a Helm chart
- Existing application changed ports, health endpoints, env vars
- Before any chart design work

#### Steps

1. **Identify stack and entrypoint**
   - Read `Dockerfile`, `docker/Dockerfile`, or build config
   - Find main entry: `cmd/server/main.go`, `src/app/`, `package.json` scripts
   - Note base image, exposed `EXPOSE` ports, `CMD`/`ENTRYPOINT`

2. **Extract network surface**
   - HTTP/gRPC listen ports from code or config
   - Public vs internal routes
   - WebSocket or long-lived connections

3. **Extract health endpoints**
   - Liveness path (e.g. `/health/live`, `/health`)
   - Readiness path (e.g. `/health/ready`, `/health`)
   - Startup probe needs (slow-start apps)

4. **Extract configuration**
   - Environment variables from `.env.example`, config structs, `process.env`, viper/env tags
   - Required vs optional vars
   - External dependencies: DB, Redis, Kafka, object storage

5. **Extract resource hints**
   - JVM heap flags, Go GOMAXPROCS, Node memory
   - Worker concurrency, batch sizes

6. **Extract build and image metadata**
   - Image name convention from CI workflows
   - Version source (git tag, Chart appVersion)

7. **Document findings**

#### Expected Output

```markdown
## Application Analysis: <app-name>

### Runtime
- Language / framework:
- Entrypoint:
- Base image:

### Network
- Container port(s):
- Protocol:

### Health
- Liveness:
- Readiness:

### Environment Variables
| Name | Required | Default | Purpose |
|------|----------|---------|---------|

### Dependencies
- (DB, cache, messaging, external APIs)

### Image
- Repository pattern:
- Tag strategy:

### Open Questions
- (items needing human input)
```

---

## 2. Understand Existing Helm Repository

### Skill: `read-helm-repository`

**Purpose:** Map existing Helm assets and conventions so new charts align with the platform.

#### When to Use
- Before creating a new chart
- Before updating an existing chart
- When deciding whether to extend vs create new

#### Steps

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

#### Expected Output

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

---

## 3. Analyze Deployment Requirements

### Skill: `analyze-deployment-requirements`

**Purpose:** Translate application facts and platform conventions into concrete Kubernetes deployment requirements.

#### When to Use
- After `read-application-source` and `read-helm-repository`
- Before `helm-design-proposal`

#### Steps

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

#### Expected Output

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

---

## 4. Design Helm Chart Changes

### Skill: `helm-design-proposal`

**Purpose:** Produce an approved design before implementation. **Enforces design-first workflow.**

#### When to Use
- New chart creation
- Major chart refactor (new resources, breaking value changes)
- Before `generate-helm-chart`

#### Steps

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
   - JSON Schema matching values structure
   - Mark required fields

6. **Design GitOps integration**
   - Overlay paths in `rsds-operation/gitops/overlays/`
   - Image tag pinning strategy

7. **Assess upgrade impact**
   - Breaking vs non-breaking
   - Migration steps for existing deployments

8. **Obtain approval**
   - Present design to human reviewer
   - **Do not proceed to code generation until approved** (for new/major changes)

#### Expected Output

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

---

## 5. Create or Update Jira Task

### Skill: `create-jira-task`

**Purpose:** Ensure traceability between requirements, implementation, and review.

#### When to Use
- Any workflow that produces code or chart changes
- After design proposal, before implementation

#### Steps

1. **Determine issue type**
   - Epic: new application chart or major platform chart change
   - Story: update chart for app change, add HPA/PDB, new env support
   - Task: lint fixes, dependency bumps, doc updates

2. **Write summary**
   - Format: `[Helm] <action> <chart-name> — <short reason>`
   - Example: `[Helm] Create user-service chart — new microservice deployment`

3. **Write description**
   - Link to design proposal
   - Application repo and chart path
   - Acceptance criteria (see template)

4. **Define acceptance criteria**
   - Chart passes helm lint and template
   - values.schema.json present and valid
   - GitOps overlay updated (if applicable)
   - PR merged with human approval

5. **Set metadata**
   - Component: Platform / Backend / Frontend
   - Labels: `helm`, `kubernetes`, `rsds`
   - Link to related Epic if Story/Task

6. **Break down large work**
   - Story: chart generation
   - Sub-task: GitOps overlay update
   - Sub-task: validation and PR

#### Expected Output

```markdown
## Jira Structure

### Epic (if applicable)
- Key: RSDS-XXX
- Summary:
- Description:

### Story
- Key: RSDS-XXX
- Summary:
- Acceptance Criteria:
  - [ ] ...
  - [ ] ...

### Tasks
- RSDS-XXX: Generate chart templates
- RSDS-XXX: Update GitOps overlay
- RSDS-XXX: Run validation and open PR
```

---

## 6. Generate or Update Helm Chart

### Skill: `generate-helm-chart`

**Purpose:** Implement approved Helm design as production-ready chart files.

#### When to Use
- After design approval and Jira task creation
- Before `helm-validate`

#### Prerequisites
- Approved design proposal
- Application analysis and deployment requirements docs
- Target repository checked out

#### Steps

1. **Scaffold or open chart directory**
   - New: create full structure per rules section 3
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

#### RSDS Template Patterns

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

#### Expected Output

- Modified/created files under chart path
- List of files changed
- Brief implementation notes vs design

---

## 7. Validate Helm Chart

### Skill: `helm-validate`

**Purpose:** Catch errors before human review. **Required gate — no PR without validation.**

#### When to Use
- After `generate-helm-chart`
- Before `generate-pr-description`

#### Steps

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

#### Expected Output

```markdown
## Helm Validation Report: <chart-name>

### Commands Run
- helm dependency update: PASS/FAIL
- helm lint: PASS/FAIL
- helm template: PASS/FAIL
- kubeconform: PASS/FAIL/SKIPPED

### Issues
| Severity | File | Issue | Resolution |

### Verdict: PASS / FAIL
```

---

## 8. Generate Deployment Verification Checklist

### Skill: `generate-deployment-checklist`

**Purpose:** Give operators concrete steps to verify chart changes after merge.

#### When to Use
- After `helm-validate` passes
- Included in PR description and runbooks

#### Steps

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

#### Expected Output

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

---

## 9. Generate Pull Request

### Skill: `generate-pr-description`

**Purpose:** Produce reviewer-ready PR descriptions that meet RSDS quality standards.

#### When to Use
- After validation passes
- Final step before opening PR (human submits/merges)

#### Steps

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

#### PR Template

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
- [ ] Resource names ≤ 63 characters
- [ ] GitOps overlay updated (if applicable)
- [ ] CHANGELOG updated
```

---

## 10. Human Review and Approval

### Manual Step

- Review PR against `GLOBAL RULES` (see below)
- Run local validation if desired
- Verify Jira linkage
- Approve or request changes
- Merge triggers CI (`helm-lint-all.yml`, `gitops-validate.yml`)
- GitOps promotion to dev/staging/prod is a **separate manual/approved process**

---

## Workflow Execution Flow

```
Request
  ↓
Analyze Application Source        (Skill: read-application-source)
  ↓
Understand Helm Repository        (Skill: read-helm-repository)
  ↓
Analyze Deployment Requirements   (Skill: analyze-deployment-requirements)
  ↓
Design Helm Chart Changes         (Skill: helm-design-proposal)
  ↓
Human Design Approval             [GATE — do not proceed without approval for new/major changes]
  ↓
Create Jira Task                  (Skill: create-jira-task)
  ↓
Generate / Update Helm Chart      (Skill: generate-helm-chart)
  ↓
Validate Helm Chart               (Skill: helm-validate)
  ↓
Generate Deployment Checklist     (Skill: generate-deployment-checklist)
  ↓
Generate Pull Request             (Skill: generate-pr-description)
  ↓
Human Review and Approval         [GATE — human merges; AI never deploys]
```

---

## Workflow Rules

### HARD CONSTRAINTS

1. **Analyze Before Designing**
   - Never propose chart structure without application source analysis.

2. **Design Before Implementation**
   - No chart file generation before design approval (new charts and major changes).

3. **Reuse First**
   - Always prefer existing charts and `helm/library/rsds-common` over duplicated templates.

4. **Never Assume Application Behavior**
   - Ports, probes, and env vars must come from source analysis — not defaults.

5. **Validation Required**
   - No PR without passing `helm-validate` skill output.

6. **Traceability**
   - Every change MUST link to a Jira ticket.

7. **Human Final Control**
   - AI NEVER deploys, applies, or merges to production. PR + human approval only.

8. **Environment Separation**
   - Chart defaults are env-agnostic; prod/staging specifics live in GitOps overlays.

---

## GLOBAL HELM RULES

All chart work must follow these rules. Every skill references them; they are not optional.

### 1. Application Analysis

- Never assume ports, health endpoints, env vars, or runtime behavior without reading application source.
- Inspect: `Dockerfile`, entrypoint, `package.json` / `go.mod`, config files, and OpenAPI specs.
- Map runtime requirements: HTTP vs gRPC, worker vs API, background jobs, migration hooks.
- Document discovered env vars in `values.yaml` comments and `values.schema.json` where applicable.

### 2. Repository Analysis

Before creating or editing charts:

1. Scan existing chart locations and naming patterns.
2. Identify reusable library charts (`helm/library/rsds-common`).
3. Match label, annotation, and helper naming already in use.
4. Prefer extending an existing chart over creating a duplicate.

**RSDS chart locations:**

| Repo | Path | Purpose |
|------|------|---------|
| rsds-frontend | `deploy/helm/rsds-frontend/` | Frontend application |
| rsds-backend | `deploy/helm/services/<service>/` | Per-microservice charts |
| rsds-operation | `helm/library/` | Shared templates |
| rsds-operation | `helm/platform/` | Cluster platform components |
| rsds-operation | `helm/umbrella/` | Bundled platform releases |

Environment-specific values belong in `rsds-operation/gitops/overlays/`, not baked into application charts.

### 3. Chart Structure

Every application chart must include:

```text
<chart-name>/
├── Chart.yaml
├── values.yaml
├── values.schema.json      # required for application charts
├── templates/
│   ├── _helpers.tpl
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── serviceaccount.yaml
│   ├── ingress.yaml        # if HTTP exposed
│   ├── hpa.yaml            # if autoscaling needed
│   └── pdb.yaml            # prod-facing services
└── .helmignore
```

- `Chart.yaml`: valid SemVer `version`; `appVersion` tracks container tag default.
- `type: application` for deployable charts; `type: library` for shared templates only.
- One chart per independently deployable unit (service, frontend app).

### 4. Templates

- Use `_helpers.tpl` for labels, fullnames, and selectors — never duplicate label blocks.
- Include library chart dependency on `rsds-common` when available:

```yaml
dependencies:
  - name: rsds-common
    version: "0.x.x"
    repository: "file://../../../../rsds-operation/helm/library/rsds-common"
```

- Template all Kubernetes names via helpers: `{{ include "chart.fullname" . }}`.
- Use `{{- with .Values... }}` blocks for optional sections.
- Never hardcode environment names, URLs, or secrets in templates.

### 5. values.yaml Management

- Provide sensible defaults for dev; leave prod overrides to GitOps overlays.
- Group values logically: `image`, `service`, `ingress`, `resources`, `autoscaling`, `podSecurityContext`.
- Image tag default: empty string with `default .Chart.AppVersion` in templates.
- Document non-obvious keys with `#` comments.
- Maintain `values.schema.json` aligned with `values.yaml`.

### 6. Helper Templates

Standard helpers every application chart should define:

- `<chart>.name` — chart short name
- `<chart>.fullname` — release-scoped resource name
- `<chart>.labels` — standard Kubernetes recommended labels
- `<chart>.selectorLabels` — pod/service selector labels

Reuse `rsds-common` helpers when the dependency is declared.

### 7. Labels and Annotations

Required labels on all resources:

```yaml
app.kubernetes.io/name: {{ include "<chart>.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: rsds
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
```

Add `app.kubernetes.io/component` for multi-component charts.

### 8. Naming Conventions

| Item | Convention | Example |
|------|------------|---------|
| Chart name | kebab-case, matches service/app | `user-service` |
| Release name | kebab-case | `user-service` |
| Values keys | camelCase | `replicaCount` |
| Template files | lowercase, kind name | `deployment.yaml` |
| Helper prefix | chart name | `user-service.fullname` |

### 9. Kubernetes Best Practices

- Set `resources.requests` and `resources.limits` on every container.
- Define liveness and readiness probes matching actual app endpoints.
- Run as non-root where the application supports it (`securityContext`).
- Use `ServiceAccount` per chart; disable automount if not needed.
- Add `PodDisruptionBudget` for services with `replicaCount >= 2`.
- Add `HorizontalPodAutoscaler` for production-facing HTTP services.
- Prefer `ClusterIP` services; expose via Ingress, not `LoadBalancer`, unless required.

### 10. Security

- Never commit secrets in `values.yaml` or templates.
- Reference secrets via External Secrets Operator or sealed secrets in GitOps overlays.
- Set `readOnlyRootFilesystem: true` when compatible.
- Drop all capabilities by default; add only what is required.
- Run containers as non-root UID when possible.
- Validate rendered manifests for overly permissive RBAC or `hostPath` mounts.

### 11. Environment Separation

- Application charts: environment-agnostic defaults.
- GitOps overlays (`gitops/overlays/dev|staging|prod/`): replicas, resources, ingress hosts, env URLs.
- Never embed `dev`, `staging`, or `prod` in chart template logic.

### 12. Chart Dependency Management

- Pin dependency versions in `Chart.yaml`; run `helm dependency update` before lint.
- Library charts must not create standalone releases.
- Document breaking changes in library charts in CHANGELOG; bump minor/major accordingly.

### 13. Reusable Templates

- Extract repeated patterns into `helm/library/rsds-common`.
- Do not copy-paste Deployment/Service blocks across service charts.
- When three or more charts share a pattern, promote to library chart.

### 14. Upgrade Compatibility

- Avoid renaming values keys without deprecation period.
- Document breaking value changes in chart CHANGELOG and PR description.
- Keep `replicaCount`, `image.repository`, and probe paths backward compatible unless major version bump.

### 15. Backward Compatibility

- Patch: bug fixes, non-breaking template fixes.
- Minor: new optional values, new optional resources (HPA, PDB).
- Major: removed values, renamed resources, probe/path changes, port changes.

### 16. Validation

Before any PR, run:

```bash
helm lint <chart-path>
helm template <release-name> <chart-path> --values <chart-path>/values.yaml
helm template <release-name> <chart-path> --values gitops/overlays/dev/<app>/values.yaml  # if overlay exists
```

Optional (recommended in CI):

```bash
# kubeconform against rendered manifests
helm template ... | kubeconform -summary -
```

Validation checklist:
- [ ] `helm lint` passes
- [ ] `helm template` renders without error
- [ ] `values.schema.json` validates sample values
- [ ] Naming consistent with repo conventions
- [ ] Dependencies resolve
- [ ] No secrets in rendered output
- [ ] Probes match application health endpoints
- [ ] Resource names ≤ 63 characters

### 17. Documentation

Every new or updated chart must include:

- Inline comments in `values.yaml` for non-obvious keys
- Update to service/app `README.md` deploy section if chart location or required values change
- PR description per workflow output template

### 18. Pull Request Quality

Every Helm chart PR must include:

- **Summary** — what changed
- **Why** — link to Jira ticket or requirement
- **Chart changes** — files added/modified
- **Kubernetes resource changes** — new/changed K8s kinds
- **Validation results** — helm lint + template output summary
- **Upgrade impact** — breaking vs non-breaking
- **Risks** — rollout, downtime, migration needs
- **Verification steps** — how reviewer validates locally or in dev

---

## Output of Workflow

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

## Cursor Integration

**Skill entry point:** `.cursor/skills/helm-chart-generator/SKILL.md`

**Quick start in Cursor:**

```
Invoke skill: helm-chart-generator
```

**What Cursor executes:**

1. Reads this workflow document
2. Executes phases 1-10 in order
3. Calls skills from `skills/` directory
4. Never skips validation or design gates
5. Outputs PR description ready for human review

---

## Related Repositories

| Repo | Role in workflow |
|------|------------------|
| rsds-frontend | Source + `deploy/helm/rsds-frontend/` |
| rsds-backend | Source + `deploy/helm/services/<svc>/` |
| rsds-operation | Library charts, GitOps overlays, this workflow |

---

## Summary

- **9 skills** orchestrated in strict order
- **2 approval gates** (design + PR review)
- **18 global rules** enforced throughout
- **AI never deploys** — PR + human approval only
- **Traceability** via Jira
- **Reuse first** — templates from rsds-common
- **Analysis before design** — source code facts drive architecture

---

**Version:** 1.0  
**Last Updated:** 2026-06-28  
**Applicable to:** RSDS Frontend, Backend Services, Platform Components
