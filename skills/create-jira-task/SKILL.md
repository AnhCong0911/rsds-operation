---
name: create-jira-task
description: Create or update Jira Epic, Stories, and Tasks with acceptance criteria for Helm chart or infrastructure work. Reusable across DevOps workflows.
---

# Create Jira Task

## Purpose

Ensure traceability between requirements, implementation, and review.

## When to Use

- Any workflow that produces code or chart changes
- After design proposal, before implementation

## Steps

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

## Expected Outputs

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

## Rules Reference

Workflow traceability rule: every change must link to a Jira ticket.
