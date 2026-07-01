# subagent-dispatcher

[English](README.md) | [简体中文](README.zh-CN.md)

Make Codex actually consider subagents when work can be split.

## Install

Recommended: install from the Codex app UI.

1. Open **Plugins** in the Codex app.
2. Choose **Add plugin marketplace**.
3. Fill in:

```text
Source: sc543753481/codex-subagents-dispatcher
Git ref: main
Sparse path: leave empty
```

4. Open the new marketplace and install **Subagent Dispatcher**.
5. Open a new Codex thread so the plugin skill is loaded into the session.

Codex app deep links can open the install flow only after Codex already knows the marketplace:

```text
codex://plugins/install/subagent-dispatcher?marketplace=codex-subagents-dispatcher
```

For a first-time public install, add the marketplace in the app first, or use the installer or CLI commands below.

### CLI Install

Requires the Codex CLI to be installed and signed in.

PowerShell one-line install:

```powershell
irm https://raw.githubusercontent.com/sc543753481/codex-subagents-dispatcher/main/scripts/install.ps1 | iex
```

Recommended PowerShell install with global `AGENTS.md` authorization:

```powershell
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/sc543753481/codex-subagents-dispatcher/main/scripts/install.ps1))) -Authorize
```

macOS/Linux:

```bash
curl -fsSL https://raw.githubusercontent.com/sc543753481/codex-subagents-dispatcher/main/scripts/install.sh | sh
```

Recommended macOS/Linux install with global `AGENTS.md` authorization:

```bash
curl -fsSL https://raw.githubusercontent.com/sc543753481/codex-subagents-dispatcher/main/scripts/install.sh | env AUTHORIZE=1 sh
```

To preview the commands before running them:

```powershell
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/sc543753481/codex-subagents-dispatcher/main/scripts/install.ps1))) -DryRun
```

```bash
curl -fsSL https://raw.githubusercontent.com/sc543753481/codex-subagents-dispatcher/main/scripts/install.sh | env DRY_RUN=1 sh
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
├── .agents/plugins/marketplace.json
├── plugins/subagent-dispatcher/
│   ├── .codex-plugin/plugin.json
│   └── skills/subagent-dispatcher/
│       ├── SKILL.md
│       ├── agents/openai.yaml
│       └── references/
├── examples/
├── docs/
└── scripts/
    ├── check.ps1
    ├── install.ps1
    ├── install.sh
    └── verify-install.ps1
```

## Installation

From this repository root, run the local installer:

PowerShell:

```powershell
.\scripts\install.ps1
```

macOS/Linux:

```bash
sh ./scripts/install.sh
```

The installer runs the official Codex CLI commands for you:

```powershell
codex plugin marketplace add .
codex plugin add subagent-dispatcher@codex-subagents-dispatcher
```

If your Codex build discovers local marketplace files differently, install from the marketplace name shown by:

```powershell
codex plugin list
```

You can also install directly from GitHub without cloning:

```powershell
codex plugin marketplace add sc543753481/codex-subagents-dispatcher --ref main
codex plugin add subagent-dispatcher@codex-subagents-dispatcher
```

To verify a local install after running the installer:

```powershell
.\scripts\verify-install.ps1
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

## Validation

Run the lightweight repository check:

```powershell
.\scripts\check.ps1
```

This checks required files, manifest consistency, marketplace pointers, standing authorization documentation, one-line installer documentation, language-switch links, and common template leftovers.

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
