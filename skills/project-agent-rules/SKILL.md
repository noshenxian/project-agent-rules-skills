---
name: project-agent-rules
description: Use when creating, adapting, or updating project-level AGENTS.md rules for a new or existing software project
---

# Project Agent Rules

## Overview

Create project-specific `AGENTS.md` rules by analyzing the actual project, not by choosing a fixed profile. The output is a concise section that tells future agents which workflows, skills, gstack commands, risks, and verification gates apply to this project.

## Workflow

1. Read the current `AGENTS.md` if present, plus `README.md`, package/config files, test setup, and top-level directories.
2. Identify project signals: domain, stack, runtime, data stores, external services, deployment target, test strategy, and high-risk failure modes.
3. Select process routing: required superpowers skills first, then gstack commands for product, architecture, design, QA, ship, or deployment stages.
4. Draft only the project-specific section. Do not overwrite generic rules.
5. Ask for confirmation when the section changes project scope, security posture, deployment flow, or test requirements.
6. Apply the section using stable markers, then verify the resulting `AGENTS.md`.

## Project Signals

Use these signals to shape rules:

| Signal | Look for | Rule impact |
| --- | --- | --- |
| Runtime | OpenResty, Node, Python, Go, browser, mobile | Required test runner and local run commands |
| Boundary | plugin, API, app, CLI, worker, library | Architecture and module rules |
| State | database, cache, queue, files, external API | Data safety and migration rules |
| Risk | auth, money, PII, cache, deploy, concurrency | Security, QA, and review gates |
| Delivery | package, Docker, service, extension, static site | ship/deploy verification |

If signals are missing, write assumptions explicitly instead of inventing project rules.

## Rule Section Shape

Use this section shape inside `AGENTS.md`:

```markdown
<!-- PROJECT_AGENT_RULES_START -->
## Project-Specific Agent Rules

### Project Signals
[stack, runtime, domain, risks, delivery target]

### Required Routing
[superpowers and gstack routing for this project]

### Engineering Rules
[architecture, testing, safety, performance, deployment constraints]

### Verification Gates
[commands or manual checks required before completion]
<!-- PROJECT_AGENT_RULES_END -->
```

Do not overwrite unrelated user content. Replace only the text between `PROJECT_AGENT_RULES` markers. If no marker exists, append the section near the end of `AGENTS.md`.

Use `scripts/apply-agents-section.sh` for deterministic marker replacement.

## Skill and gstack Routing

- New feature, new project, or architecture choice: use `superpowers:brainstorming` before design.
- Implementation or bugfix: use `superpowers:test-driven-development`; if a failure exists, use `superpowers:systematic-debugging` first.
- Multi-step plan: use `superpowers:writing-plans` before edits.
- Completion claim: use `superpowers:verification-before-completion`.
- Product or project from zero: route through gstack `/office-hours`, then `/autoplan` or `/plan-eng-review`.
- Design-heavy work: use `/plan-design-review`, `/design-consultation`, `/design-shotgun`, or `/design-review` as appropriate.
- QA, release, deploy: use `/review`, `/qa` or `/qa-only`, `/ship`, `/land-and-deploy`, `/canary`.
- Security or data leakage risk: use `/cso`; performance risk: use `/benchmark`.

If a gstack command and a superpowers skill overlap, use superpowers to enforce process discipline and gstack for stage-specific product or engineering review. Do not repeat equivalent reviews unless the first one leaves gaps.

## Common Mistakes

| Mistake | Correction |
| --- | --- |
| Copying a fixed profile without reading the project | Scan project signals first |
| Replacing the whole `AGENTS.md` | Do not overwrite generic rules or user content |
| Listing every possible skill | Route only skills triggered by project signals |
| Writing vague rules like "test carefully" | Name concrete commands or verification gates |
| Ignoring risk-specific rules | Add explicit gates for auth, cache, PII, money, deploy, concurrency |

