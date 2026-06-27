---
name: read-application-source
description: Analyze application source code in a Git repository to extract runtime, ports, health checks, env vars, and deployment requirements for Helm chart generation.
---

# Read Application Source

## Purpose

Extract deployment-relevant facts from application source code before designing or updating a Helm chart.

## When to Use

- New application needs a Helm chart
- Existing application changed ports, health endpoints, env vars, or runtime
- Any workflow step that requires understanding how the app runs in a container

## Prerequisites

- Application repository path or clone URL
- Application name and type (frontend, API service, worker)

## Steps

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

## Expected Outputs

Structured summary:

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

## Rules Reference

Follow `rules/helm-chart.md` sections 1 (Application Analysis) and 10 (Security).
