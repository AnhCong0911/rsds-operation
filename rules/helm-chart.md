# Helm Chart Global Rules

Global rules for Helm chart development in the RSDS platform. All AI workflows and skills that touch Helm charts **must** follow these rules.

Applies to:
- Application charts in `rsds-frontend/deploy/helm/` and `rsds-backend/deploy/helm/services/`
- Platform charts in `rsds-operation/helm/platform/`
- Library charts in `rsds-operation/helm/library/`
- GitOps overlays in `rsds-operation/gitops/`

---

## 1. Application Analysis

- Never assume ports, health endpoints, env vars, or runtime behavior without reading application source.
- Inspect: `Dockerfile`, entrypoint, `package.json` / `go.mod`, config files, and OpenAPI specs.
- Map runtime requirements: HTTP vs gRPC, worker vs API, background jobs, migration hooks.
- Document discovered env vars in `values.yaml` comments and `values.schema.json` where applicable.

## 2. Repository Analysis

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

## 3. Chart Structure

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

## 4. Templates

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

## 5. values.yaml Management

- Provide sensible defaults for dev; leave prod overrides to GitOps overlays.
- Group values logically: `image`, `service`, `ingress`, `resources`, `autoscaling`, `podSecurityContext`.
- Image tag default: empty string with `default .Chart.AppVersion` in templates.
- Document non-obvious keys with `#` comments.
- Maintain `values.schema.json` aligned with `values.yaml`.

## 6. Helper Templates

Standard helpers every application chart should define:

- `<chart>.name` — chart short name
- `<chart>.fullname` — release-scoped resource name
- `<chart>.labels` — standard Kubernetes recommended labels
- `<chart>.selectorLabels` — pod/service selector labels

Reuse `rsds-common` helpers when the dependency is declared.

## 7. Labels and Annotations

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

## 8. Naming Conventions

| Item | Convention | Example |
|------|------------|---------|
| Chart name | kebab-case, matches service/app | `user-service` |
| Release name | kebab-case | `user-service` |
| Values keys | camelCase | `replicaCount` |
| Template files | lowercase, kind name | `deployment.yaml` |
| Helper prefix | chart name | `user-service.fullname` |

## 9. Kubernetes Best Practices

- Set `resources.requests` and `resources.limits` on every container.
- Define liveness and readiness probes matching actual app endpoints.
- Run as non-root where the application supports it (`securityContext`).
- Use `ServiceAccount` per chart; disable automount if not needed.
- Add `PodDisruptionBudget` for services with `replicaCount >= 2`.
- Add `HorizontalPodAutoscaler` for production-facing HTTP services.
- Prefer `ClusterIP` services; expose via Ingress, not `LoadBalancer`, unless required.

## 10. Security

- Never commit secrets in `values.yaml` or templates.
- Reference secrets via External Secrets Operator or sealed secrets in GitOps overlays.
- Set `readOnlyRootFilesystem: true` when compatible.
- Drop all capabilities by default; add only what is required.
- Run containers as non-root UID when possible.
- Validate rendered manifests for overly permissive RBAC or `hostPath` mounts.

## 11. Environment Separation

- Application charts: environment-agnostic defaults.
- GitOps overlays (`gitops/overlays/dev|staging|prod/`): replicas, resources, ingress hosts, env URLs.
- Never embed `dev`, `staging`, or `prod` in chart template logic.

## 12. Chart Dependency Management

- Pin dependency versions in `Chart.yaml`; run `helm dependency update` before lint.
- Library charts must not create standalone releases.
- Document breaking changes in library charts in CHANGELOG; bump minor/major accordingly.

## 13. Reusable Templates

- Extract repeated patterns into `helm/library/rsds-common`.
- Do not copy-paste Deployment/Service blocks across service charts.
- When three or more charts share a pattern, promote to library chart.

## 14. Upgrade Compatibility

- Avoid renaming values keys without deprecation period.
- Document breaking value changes in chart CHANGELOG and PR description.
- Keep `replicaCount`, `image.repository`, and probe paths backward compatible unless major version bump.

## 15. Backward Compatibility

- Patch: bug fixes, non-breaking template fixes.
- Minor: new optional values, new optional resources (HPA, PDB).
- Major: removed values, renamed resources, probe/path changes, port changes.

## 16. Validation

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

## 17. Documentation

Every new or updated chart must include:

- Inline comments in `values.yaml` for non-obvious keys
- Update to service/app `README.md` deploy section if chart location or required values change
- PR description per workflow output template

## 18. Pull Request Quality

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

## Enforcement

Workflows inherit these rules. Skills must reference `rules/helm-chart.md` instead of duplicating rule text.

**Hard constraints:**
- AI must never deploy or apply charts to any cluster.
- AI must never merge PRs — human approval required.
- Design proposal must precede chart generation for new charts or major changes.
