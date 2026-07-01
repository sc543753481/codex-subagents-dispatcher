# subagent-dispatcher

[English](README.md) | [简体中文](README.zh-CN.md)

[![Repository check](https://github.com/sc543753481/codex-subagents-dispatcher/actions/workflows/check.yml/badge.svg)](https://github.com/sc543753481/codex-subagents-dispatcher/actions/workflows/check.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

Make Codex actually consider subagents when work can be split.

## Why It Exists

Codex subagents are powerful, but Codex often needs explicit permission and clear dispatch rules before it uses them well.

`subagent-dispatcher` gives Codex a reusable workflow for deciding when to split work, how many agents to use, what each agent owns, and how the main agent should synthesize the result.

## Fast Proof

After installing, try this in a project with several independent areas to inspect:

```text
Use subagent-dispatcher. Inspect this repository with read-only subagents: one for install flow, one for plugin manifest, one for examples/docs, and one for validation gaps. Synthesize the result into priorities.
```

Expected behavior: Codex should announce the split, keep each agent focused, then return one synthesized answer instead of dumping separate notes.

## Install

Recommended for most users: install with the Codex CLI one-line installer. It avoids the most common UI mistake: typing text into the sparse path field.

Requirements:

- Codex CLI installed.
- Signed in to Codex.

PowerShell, recommended with global `AGENTS.md` authorization:

```powershell
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/sc543753481/codex-subagents-dispatcher/main/scripts/install.ps1))) -Ref main -Authorize
```

macOS/Linux, recommended with global `AGENTS.md` authorization:

```bash
curl -fsSL https://raw.githubusercontent.com/sc543753481/codex-subagents-dispatcher/main/scripts/install.sh | env REF=main AUTHORIZE=1 sh
```

The authorization step adds the standing instruction that lets Codex consider the `subagent-dispatcher` workflow automatically when work can be split.

After installing, open a new Codex thread so the plugin skill is loaded. To verify the install, run:

```powershell
codex plugin list
```

You should see `subagent-dispatcher@codex-subagents-dispatcher` marked as installed and enabled.

### Codex App UI

You can also add the marketplace from the Codex app UI.

1. Open **Plugins** in the Codex app.
2. Choose **Add plugin marketplace**.
3. Fill in only these fields:

| Field | Value |
| --- | --- |
| Source | `https://github.com/sc543753481/codex-subagents-dispatcher.git` |
| Git ref | `main` |

Important: do not type `leave empty`, `plugins/subagent-dispatcher`, or any other text into **Sparse path**. The field must be empty. This repository is a marketplace repo, and Codex needs the root `.agents/plugins/marketplace.json` file plus the plugin folder it points to.

If you see `marketplace root does not contain a supported manifest`, the sparse path was probably set incorrectly. Retry with **Sparse path** completely empty, or use the one-line installer above.

4. Open the new marketplace, **Codex Subagents Dispatcher**.
5. Install **Subagent Dispatcher**.
6. Open a new Codex thread so the plugin skill is loaded into the session.

Codex app deep links can open the install flow only after Codex already knows the marketplace:

```text
codex://plugins/install/subagent-dispatcher?marketplace=codex-subagents-dispatcher
```

For a first-time public install, add the marketplace with the one-line installer, the UI flow above, or the manual CLI commands below.

### Manual CLI

Install directly from GitHub without cloning:

```powershell
codex plugin marketplace add sc543753481/codex-subagents-dispatcher --ref main
codex plugin add subagent-dispatcher@codex-subagents-dispatcher
```

If you want to install without writing `AGENTS.md` automatically, use:

```powershell
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/sc543753481/codex-subagents-dispatcher/main/scripts/install.ps1))) -Ref main
```

```bash
curl -fsSL https://raw.githubusercontent.com/sc543753481/codex-subagents-dispatcher/main/scripts/install.sh | env REF=main sh
```

To preview the installer commands before running them:

```powershell
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/sc543753481/codex-subagents-dispatcher/main/scripts/install.ps1))) -DryRun
```

```bash
curl -fsSL https://raw.githubusercontent.com/sc543753481/codex-subagents-dispatcher/main/scripts/install.sh | env DRY_RUN=1 sh
```

### Local Development Install

From this repository root, run the local installer:

PowerShell:

```powershell
.\scripts\install.ps1 -Source . -Authorize
```

macOS/Linux:

```bash
env AUTHORIZE=1 sh ./scripts/install.sh .
```

The installer runs the official Codex CLI commands for you:

```powershell
codex plugin marketplace add .
codex plugin add subagent-dispatcher@codex-subagents-dispatcher
```

To verify a local install from a cloned checkout:

```powershell
.\scripts\verify-install.ps1
```

## Overview

`subagent-dispatcher` is a general-purpose OpenAI Codex plugin that gives Codex standing authorization, dispatch rules, safety limits, and reusable prompts for using subagents on parallelizable work.

It does not automatically create or start subagents. Codex still needs a runtime that exposes subagent tools, and current Codex behavior usually expects user authorization before spawning subagents. This plugin supplies the missing workflow layer: when to split, how many agents to use, which roles to assign, and how the main agent should synthesize results.

## When To Use

Subagents are useful, but many Codex sessions still behave like one agent working through everything sequentially. That is fine for small tasks, but it is slow for work that naturally splits into independent lanes.

Typical split points include:

- Checking config, logs, history, and installed plugins in parallel.
- Comparing several tools, products, vendors, or documents.
- Investigating multiple unrelated test failures.
- Reviewing separate evidence lanes before a recommendation.
- Assigning implementation workers only when write scopes do not overlap.

This plugin guides Codex toward a better operating mode for parallel work: main agent as dispatcher, subagents as focused workers, main agent as synthesizer.

## Capabilities

- Decides whether a task is worth splitting.
- Defines default dispatch limits: 5 subagents normally, 8 for read-only research, 3 for code-editing workers.
- Separates `explorer`, `worker`, `reviewer`, and `synthesizer` style prompts.
- Covers coding and non-coding tasks.
- Requires the main agent to announce the split, set read/write boundaries, review outputs, and synthesize one coherent result.
- Documents when not to use subagents.

## Limits / Non-Goals

- It does not create Codex subagent tools by itself.
- It does not bypass Codex permissions or product limits.
- It does not guarantee every task gets faster.
- It does not make overlapping file edits safe.
- It does not install custom agents through `plugin.json`; current Codex plugin manifests do not provide that as a stable general mechanism.

## Repository Layout

```text
.
├── README.md
├── README.zh-CN.md
├── .github/workflows/check.yml
├── .agents/plugins/marketplace.json
├── plugins/subagent-dispatcher/
│   ├── .codex-plugin/plugin.json
│   └── skills/subagent-dispatcher/
│       ├── SKILL.md
│       ├── agents/openai.yaml
│       └── references/
├── examples/
├── docs/
│   └── launch-checklist.md
└── scripts/
    ├── check.ps1
    ├── install.ps1
    ├── install.sh
    └── verify-install.ps1
```

## AGENTS.md Authorization

For best results, add this to your user or project `AGENTS.md`:

```text
When a task can be split into independent workstreams, prefer the subagent-dispatcher workflow and use up to 5 subagents by default, up to 8 for read-only research. Before spawning subagents, briefly state the split, whether each agent is read-only or may edit files, and how results will be synthesized.
```

This matters because Codex subagents are usually spawned only when the user has clearly authorized subagent or delegation work.

The installer can add this to your global Codex instructions with `-Authorize` on PowerShell or `AUTHORIZE=1` on macOS/Linux.

## Quick Test

After installing in a new thread, try:

```text
Use subagent-dispatcher. Inspect this project by splitting the work into read-only subagents: one for plugin manifest, one for skill trigger behavior, one for examples/docs, and one for validation gaps. Synthesize the result.
```

Expected behavior: Codex should explain the split before dispatching, keep agents focused, and merge their results instead of directly listing separate subagent summaries.

If your Codex runtime does not expose subagent tools, a valid fallback is for Codex to say that subagent tooling is unavailable, keep the same split inline, and synthesize the result itself.

## Examples

- See [examples/research.md](examples/research.md) for multi-source product or tool comparison.
- See [examples/debugging.md](examples/debugging.md) for config/log/history diagnosis.
- See [examples/coding.md](examples/coding.md) for independent coding failures and write-scope safety.
- See [docs/launch-checklist.md](docs/launch-checklist.md) for repository launch and promotion steps.

## Validation

Run the lightweight repository check:

```powershell
.\scripts\check.ps1
```

This checks required files, manifest consistency, marketplace pointers, standing authorization documentation, one-line installer documentation, language-switch links, and common template leftovers.

The same check runs in GitHub Actions on pushes and pull requests.

Verify that Codex can see the installed plugin:

```powershell
.\scripts\verify-install.ps1
```

For Codex plugin validation, use the `plugin-creator` and `skill-creator` validators from your Codex environment if available.

## Design Notes

The design is intentionally simple:

- Use a Codex skill, not an MCP server.
- Keep the dispatch rules in Markdown so Codex can reason about them.
- Keep examples and limits separate from the main skill for progressive disclosure.
- Treat subagent results as evidence to review, not truth to blindly trust.

See [docs/design.md](docs/design.md) for the full design rationale.

## License

MIT
