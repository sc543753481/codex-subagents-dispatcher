# Design

`subagent-dispatcher` is a Codex workflow plugin, not a new agent runtime.

## Goals

- Make Codex more likely to consider subagents when a task is parallelizable.
- Give Codex concrete limits, role patterns, and prompt templates.
- Cover coding and non-coding tasks.
- Make dispatch transparent to the user before agents are spawned.
- Keep result synthesis owned by the main agent.

## Non-Goals

- Do not bypass Codex product permissions.
- Do not promise fully automatic spawning in every session.
- Do not define custom agents inside `plugin.json`.
- Do not encourage overlapping writes.
- Do not add an MCP server for a problem that can be solved with skill guidance.

## Why A Skill

The missing layer is judgment: when to split work, which roles to use, what limits to apply, and how to synthesize results. Markdown skill guidance is enough for that. It also keeps the project portable and easy to inspect.

## Standing Authorization

Current Codex behavior generally expects explicit user authorization before spawning subagents. This project recommends adding an `AGENTS.md` instruction so Codex can treat parallelizable tasks as authorized for subagent consideration.

## Limits

The default limit is intentionally aggressive but bounded:

- 5 subagents for normal parallel work.
- 8 for read-only research and document review.
- 3 for code-editing workers.
- 1-2 for reviewers.

The code-editing limit is lower because integration risk rises quickly when multiple agents can mutate the same project.

## Trust Model

Subagent output is evidence, not truth. The main agent remains responsible for reviewing evidence, reconciling conflicts, verifying critical claims, and producing one coherent final answer or implementation.
