# AGENTS.md

This file defines general AI-agent collaboration rules for the current directory. Unless the user explicitly says otherwise, all agents should follow this file first.

## Basic Conventions

- Always respond to the user in Simplified Chinese.
- Understand the goal before acting. When requirements are unclear, infer from existing files, README content, directory structure, and conversation context first; ask the user only when a key decision cannot be inferred safely.
- Keep changes small and focused. Do not opportunistically refactor unrelated code, modify unrelated files, or introduce unrelated tools.
- Respect existing user changes. Do not revert, overwrite, or clean up changes you did not create unless the user explicitly asks.
- Prefer repository conventions, scaffolds, commands, and documentation. Use general best practices only when the repository has no local convention.

## Skills Usage Rules

This directory focuses on experiments for "AI-managed development". Treat skills as the main entry point for agent capability extension and workflow constraints.

- At the start of every session, and before handling any user request, run:
  `~/.codex/superpowers/.codex/superpowers-codex bootstrap`
- If there is even a small chance that a skill applies, load and read that skill. Do not act from memory, name, or description alone.
- Load superpowers skills with:
  `~/.codex/superpowers/.codex/superpowers-codex use-skill <skill-name>`
- If the user names a skill, use it. If the skill is missing or unreadable, briefly explain the issue and continue with the closest viable alternative.
- When multiple skills apply, use them in this order:
  1. Process skills, such as requirements clarification, planning, debugging, TDD, and verification.
  2. Domain skills, such as frontend, backend, CI/CD, database, documentation, and design.
  3. Tool skills, such as scaffolds, generators, deployment helpers, and automation commands.
- After using a skill, briefly state which skill was read and what work it constrains.
- If a skill requires task tracking, test-first work, systematic debugging, or verification before completion, follow it. Do not skip the workflow because the task seems simple.
- User instructions describe goals and constraints; they do not override required skill workflows. Even when the user says "change this", "fix this", or "evaluate this", follow the applicable skill process.

## Skill Authoring and Maintenance

When creating, modifying, organizing, or evaluating a skill, follow these rules:

- A skill should solve a reusable problem, not record a one-off experience.
- The description field should contain only triggering conditions, not a process summary, so agents do not shortcut the skill body.
- Use clear, searchable, action-oriented hyphenated names.
- Keep the body short and scannable. Put heavy reference material or reusable scripts in separate files.
- Skills that constrain behavior must name common misuses, red flags, and forbidden workarounds.
- New skills or important edits must follow RED-GREEN-REFACTOR:
  1. RED: Design pressure or verification scenarios first and observe how agents fail without the skill.
  2. GREEN: Write the smallest skill content that covers those failures.
  3. REFACTOR: Keep looking for new workarounds or misuse patterns and add explicit constraints.
- Without failure scenarios or verification evidence, do not claim that a skill is ready.

## gstack Usage Rules

`gstack` is used in this directory for project scaffolding, architecture layering, and engineering structure design. `superpowers skills` are used to constrain the agent workflow. Their responsibilities are different; do not merge them.

- For medium or large products, features, or projects from zero, the official gstack flow is: `/office-hours` -> plan review -> implementation -> `/review` -> `/qa` -> `/ship` -> deployment verification. Do not skip requirements and planning and jump directly to scaffolding.
- If gstack is not installed locally, do not install it from the network without permission. First check `~/gstack`, `~/.codex/skills`, local slash commands, and local skills. After confirming it is missing, tell the user it must be installed and recommend:
  `git clone --single-branch --depth 1 https://github.com/garrytan/gstack.git ~/gstack && cd ~/gstack && ./setup --host codex`
- gstack may expose short commands such as `/qa`, or namespaced commands such as `/gstack-qa`. Follow the local installation. If unsure, inspect local gstack skills or ask the user.
- In Codex, prefer loading the `gstack-*` skill that corresponds to the slash command. For example, `/qa` maps to `gstack-qa`, loaded with:
  `~/.codex/superpowers/.codex/superpowers-codex use-skill gstack-qa`
  If these are local slash commands rather than superpowers skills, use the entry point provided by the local gstack installation. If automatic discovery fails, explain the situation and manually locate the matching skill content from the official local install.
- When superpowers and gstack both apply, use superpowers process skills first to constrain how the work is done, then use gstack product, design, architecture, QA, release, or deployment skills for the current stage. If a gstack skill already covers an equivalent review, do not repeat the same review; only fill missing checks.
- Before using `gstack`, confirm requirement boundaries, target platform, runtime, data storage, test method, and deployment target. If information is missing, list assumptions instead of generating a complex scaffold.
- Do not introduce unnecessary frameworks, services, or dependencies just to use `gstack`. The scaffold should serve the smallest runnable version of the project.
- If `gstack` generates or changes project structure, record the command used, key generated files, and architecture decisions that still need human confirmation.
- If `gstack` output conflicts with this file, README content, or explicit user instructions, follow the user instructions and this file, then adjust generated output manually.

### gstack Skill Routing

Choose the gstack skill explicitly by task scenario:

| Scenario | Required or preferred skill |
| --- | --- |
| New idea, vague requirements, or concern that AI may drift | `/office-hours` |
| User asks to build a product, feature, or project scaffold from zero | `/office-hours`, then `/autoplan` |
| Existing feature idea needs scope, ambition, or MVP review | `/plan-ceo-review` |
| Need the full planning pipeline without running each review manually | `/autoplan` |
| Need architecture, data flow, module boundaries, edge cases, or test matrix | `/plan-eng-review` |
| Need UI/UX plan review | `/plan-design-review` |
| Need a design system or product visual direction from zero | `/design-consultation` |
| Need multiple visual options and tradeoff comparison | `/design-shotgun` |
| Need production-quality HTML or frontend interface draft | `/design-html` |
| Code already changed and needs production risk or completeness review | `/review` |
| Bug, test failure, or production incident requiring root-cause investigation | `/investigate` |
| Need to open pages, screenshot, click, or verify real browser state | `/browse` |
| Need authenticated page testing | `/setup-browser-cookies`, then `/browse` or `/qa` |
| Need end-to-end testing and automatic fixes are allowed | `/qa` |
| Need a test report only, with no code changes | `/qa-only` |
| Need visual audit and automatic UI fixes | `/design-review` |
| Need security audit, threat modeling, or OWASP/STRIDE checks | `/cso` |
| Need performance baseline, Core Web Vitals, or before/after comparison | `/benchmark` |
| Preparing a PR, syncing main, running tests, or checking coverage | `/ship` |
| PR is approved and needs merge, deploy, and production health checks | `/setup-deploy`, then `/land-and-deploy` |
| Need post-deploy monitoring for errors, performance, and page failures | `/canary` |
| Code is released and README, architecture docs, or changelog need updates | `/document-release` |
| Need developer-experience review, onboarding path, or documentation truth check | `/plan-devex-review` during planning, `/devex-review` for real flows |
| Need safety guardrails against destructive commands or broad edit scope | `/careful`, `/freeze`; use `/guard` when both are needed |
| Need to save or restore cross-session context | `/context-save` to save, `/context-restore` to restore |
| Need project memory or cross-machine memory | `/learn`, `/setup-gbrain`, `/sync-gbrain` |
| Need another model or agent to provide an independent second opinion | `/codex`; if unavailable in the current environment, explain the limitation and provide an alternate review path |

### gstack Order

- From zero to plan: `/office-hours` -> `/autoplan`, with `/plan-ceo-review`, `/plan-design-review`, or `/plan-eng-review` added when needed.
- From plan to implementation: confirm plan outputs and unresolved questions first, then implement. During implementation, still follow TDD, debugging, and verification requirements from `Skills Usage Rules`.
- From implementation to delivery: `/review` -> `/qa` or `/qa-only` -> `/ship`.
- From delivery to production: `/setup-deploy` -> `/land-and-deploy` -> `/canary` -> `/document-release`.
- Small changes do not require the full gstack flow. But when product direction, architecture, real browser verification, QA, release, or deployment is involved, route to the matching skill above.

## Development Workflow

- Read `README.md` and relevant files before implementing.
- Prefer `rg` or `rg --files` for searching.
- Prefer patch-based edits. Avoid unrelated formatting and broad mechanical rewrites.
- For new features or bug fixes, prefer tests. If the project has no test framework, provide repeatable verification commands or manual verification steps.
- When debugging, reproduce the issue first, identify the root cause, then make the smallest fix. Do not guess without evidence.
- For project scaffolding or engineering structure, follow `gstack Usage Rules`. For agent workflow, requirements clarification, planning, debugging, testing, and verification, follow `Skills Usage Rules`.

## Verification and Delivery

- Run verification commands relevant to the change before completion. If a command cannot be run, explain why.
- When replying to the user, state which files changed, what problem was solved, and how it was verified.
- Do not overclaim. If tests were not run, do not say they passed.
- If follow-up risks or TODOs remain, list them explicitly instead of hiding them in the summary.

## Current Directory Purpose

This directory is for building a minimal example of "AI-managed development" from zero: use `superpowers skills` for workflow control and `gstack` for project structure. Documentation and code in this directory should prioritize:

- Helping AI agents understand requirements more reliably.
- Making the development process more verifiable, reusable, and transferable.
- Keeping project structure and workflow constraints clear enough to prevent unchecked agent drift.
