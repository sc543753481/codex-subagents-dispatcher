---
name: subagent-dispatcher
description: General-purpose subagent dispatch workflow for Codex. Use when a user asks for subagents, parallel agents, delegation, worker agents, explorer agents, reviewers, multi-agent work, faster parallel work, or when a task appears splittable across independent workstreams such as multi-source research, comparing options, analyzing multiple files or documents, checking logs/config/history in parallel, debugging independent failures, auditing several subsystems, or coordinating coding and non-coding investigations.
---

# Subagent Dispatcher

## Overview

Use this skill to decide whether to dispatch subagents, define their scopes, and synthesize their results. It is intentionally general: apply it to coding, research, system diagnosis, document review, product analysis, file triage, and other tasks that can be split into independent workstreams.

This skill does not create subagent tooling by itself. Use the current Codex environment's available multi-agent tools when present, and fall back to an inline plan when those tools are unavailable.

Current Codex behavior generally expects explicit user authorization before spawning subagents. Treat this skill, an explicit user request, or a standing `AGENTS.md` authorization as that permission signal.

## Dispatch Decision

Prefer dispatching subagents when all of these are true:

- The task can be split into at least two independent workstreams.
- Each workstream has a clear scope, input context, and expected output.
- Subagents will not fight over the same files, resources, accounts, or mutable state.
- The main agent can review and synthesize results before responding or integrating changes.

Do not dispatch subagents when the task is a small single-threaded request, the root cause is likely shared, the problem needs continuous reasoning in one context, or the workstreams cannot be described precisely yet.

Use `references/decision-matrix.md` for count limits, role selection, and examples.

## Default Limits

Use an aggressive but bounded policy:

- Default batch limit: up to 5 subagents.
- Read-only research or document analysis soft limit: up to 8 subagents.
- Code-editing worker limit: up to 3 subagents, only with disjoint write scopes.
- Reviewer limit: 1-2 subagents for important implementations, complex conclusions, or high-risk decisions.

If a task needs more than the limit, dispatch in batches and synthesize between batches.

Use `references/limits-and-safety.md` before exceeding the default batch limit or before allowing any subagent to edit files.

## Required Workflow

1. Announce the intended split before dispatching.
2. Assign each subagent exactly one responsibility.
3. Pass only the context needed for that responsibility.
4. Specify whether the subagent is read-only or may edit files.
5. For editing work, define the file or module ownership boundary.
6. Continue useful non-overlapping work while subagents run.
7. Review each result before trusting it.
8. Synthesize one answer or integrated implementation.
9. Close completed subagents when no longer needed.

## Role Patterns

Use `explorer` for read-only investigation, codebase questions, source comparison, log/config/history inspection, and evidence gathering.

Use `worker` for bounded implementation when the write scope is clear and disjoint from other workers.

Use reviewer-style prompts for spec compliance, quality checks, risk review, or independent validation after an implementation or research synthesis.

Use `references/prompt-templates.md` for reusable prompts.

## Model And Reasoning

Default to inheriting the main agent's model and reasoning effort. Override only when the user requests it or the work clearly benefits from a different setting.

For simple read-only explorers, lower reasoning can be appropriate. For complex reviewers, architecture, high-risk implementation, or synthesis, keep high reasoning.

Use `references/limits-and-safety.md` for details.

## Non-Coding Tasks

For research, product analysis, planning, document review, and system diagnosis, split by evidence lane instead of technical layer. Examples: one subagent per product, data source, document, hypothesis, vendor, time period, or configuration area.

Use `references/non-coding-patterns.md` for task-specific patterns.

## Output Contract

When using subagents, the main agent should include a concise synthesis that says:

- Which subagents ran and what each covered.
- The combined conclusion or integrated change.
- Any conflicts, weak evidence, or follow-up checks.
- Any verification performed by the main agent after subagents returned.
