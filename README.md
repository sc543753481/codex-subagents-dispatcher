# subagent-dispatcher

[English](README.md) | [简体中文](README.zh-CN.md)

[![Repository check](https://github.com/sc543753481/codex-subagents-dispatcher/actions/workflows/check.yml/badge.svg)](https://github.com/sc543753481/codex-subagents-dispatcher/actions/workflows/check.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

Help Codex consider subagents when work can be split.

## Why It Exists

Codex subagents are powerful, but Codex often needs explicit permission and clear dispatch rules before it uses them well.

`subagent-dispatcher` gives Codex a reusable workflow for deciding when to split work, how many agents to use, what each agent owns, and how the main agent should synthesize the result.

It does not automatically create or start subagents. Codex still needs a runtime that exposes subagent tools, and current Codex behavior usually expects user authorization before spawning subagents. This plugin supplies the missing workflow layer.

## Install

### Recommended: Ask Codex to install it

For most users, the best install path is to ask Codex to install the plugin for you. Codex can pick the right available route for your environment, avoid common marketplace field mistakes, add the standing `AGENTS.md` authorization text if you approve it, verify the result, and remind you to open a new thread so the skill is loaded.

Copy this prompt into Codex:

```text
Please install this Codex plugin.

plugin = subagent-dispatcher
marketplace = codex-subagents-dispatcher
source = https://github.com/sc543753481/codex-subagents-dispatcher.git
ref = main
after_install = enable, verify, then ask me to start a new thread

Use the Codex CLI if available:
1. Add the marketplace from the source URL.
2. Install subagent-dispatcher@codex-subagents-dispatcher.
3. Verify with codex plugin list --json.
4. Do not report success unless the plugin is installed and enabled.
5. If I approve writing standing instructions, add the AGENTS.md authorization text from this README.
```

Use this authorization text in your user or project `AGENTS.md` so Codex has standing permission to consider this workflow:

```text
When a task can be split into independent workstreams, prefer the subagent-dispatcher workflow and use up to 5 subagents by default, up to 8 for read-only research. Before spawning subagents, briefly state the split, whether each agent is read-only or may edit files, and how results will be synthesized.
```

This matters because Codex subagents are usually spawned only when the user has clearly authorized subagent or delegation work.

### Codex App UI manual marketplace add

Requirements:

- Codex app installed.
- Signed in to Codex.
- A Codex build with the **Plugins** UI.

Steps:

1. Open **Plugins** in the Codex app.
2. Choose **Add plugin marketplace**.
3. Fill in only these fields:

| Field | Value |
| --- | --- |
| Source | `https://github.com/sc543753481/codex-subagents-dispatcher.git` |
| Git ref | `main` |

Important: fill in only the fields shown above. This repository is a marketplace repo, and Codex needs the root `.agents/plugins/marketplace.json` file plus the plugin folder it points to.

If you see `marketplace root does not contain a supported manifest`, retry the marketplace add with only **Source** and **Git ref**, or use the CLI fallback below.

4. Open the new marketplace, **Codex Subagents Dispatcher**.
5. Install **Subagent Dispatcher**.
6. Open a new Codex thread so the plugin skill is loaded into the session.

To confirm the install, the plugin should appear as installed and enabled in the app's plugin list.

Deep-link boundary: Codex app deep links are not a bootstrap installer. This deep link only works after Codex already knows the `codex-subagents-dispatcher` marketplace, for example after the manual UI marketplace add above or after `codex plugin marketplace add` succeeds:

```text
codex://plugins/install/subagent-dispatcher?marketplace=codex-subagents-dispatcher
```

### Verified CLI fallback one-line installers

Use the CLI fallback when the Plugins UI is unavailable, when you want a repeatable command, or when you want the installer to add the global `AGENTS.md` authorization text for you. The PowerShell remote installer path has been verified with a temporary `CODEX_HOME`; the shell installer is documented as the macOS/Linux equivalent.

Requirements:

- Codex CLI installed.
- Signed in to Codex.

PowerShell, with global `AGENTS.md` authorization:

```powershell
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/sc543753481/codex-subagents-dispatcher/main/scripts/install.ps1))) -Ref main -Authorize
```

macOS/Linux equivalent, with global `AGENTS.md` authorization:

```bash
curl -fsSL https://raw.githubusercontent.com/sc543753481/codex-subagents-dispatcher/main/scripts/install.sh | env REF=main AUTHORIZE=1 sh
```

After installing, open a new Codex thread so the plugin skill is loaded. If the Codex CLI is available, verify the install with:

```powershell
codex plugin list
```

You should see `subagent-dispatcher@codex-subagents-dispatcher` marked as installed and enabled.

### Manual CLI

Install directly from GitHub without cloning:

```powershell
codex plugin marketplace add sc543753481/codex-subagents-dispatcher --ref main
codex plugin add subagent-dispatcher@codex-subagents-dispatcher
```

The manual CLI commands do not write `AGENTS.md` for you. Add the authorization text above if you want Codex to consider this workflow automatically.

### Local development install

From this repository root, run the local installer. The PowerShell local development installer has been verified with a temporary `CODEX_HOME`.

PowerShell:

```powershell
.\scripts\install.ps1 -Source . -Authorize
```

macOS/Linux:

```bash
env AUTHORIZE=1 sh ./scripts/install.sh .
```

To verify a local install from a cloned checkout:

```powershell
.\scripts\verify-install.ps1
```

### Preview/install verification

Preview what the installer will run before making changes:

```powershell
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/sc543753481/codex-subagents-dispatcher/main/scripts/install.ps1))) -DryRun
```

```bash
curl -fsSL https://raw.githubusercontent.com/sc543753481/codex-subagents-dispatcher/main/scripts/install.sh | env DRY_RUN=1 sh
```

After any install path, verify with the app plugin list or with the CLI:

```powershell
codex plugin list
```

If you installed from a cloned checkout and have the Codex CLI available, run:

```powershell
.\scripts\verify-install.ps1
```

Then open a new Codex thread so the plugin skill is loaded.

Verification status for this repository:

The repository can automatically verify CLI behavior, but not app button clicks.

- Verified: PowerShell remote installer with `-Ref main -Authorize` in a temporary `CODEX_HOME`.
- Verified: PowerShell local development installer with `-Source . -Authorize` in a temporary `CODEX_HOME`.
- Verified: `scripts/verify-install.ps1` confirmed both temporary installs.
- Verified: `codex plugin marketplace add --help` and `codex plugin add --help` match the documented CLI options.
- Not automatically verified here: the Codex app UI flow and macOS/Linux shell execution.

## Quick Test

After installing in a new thread, try this in a project with several independent areas to inspect:

```text
Use subagent-dispatcher. Inspect this repository with read-only subagents: one for install flow, one for plugin manifest, one for examples/docs, and one for validation gaps. Synthesize the result into priorities.
```

Expected behavior: Codex should announce the split, keep each agent focused, then return one synthesized answer instead of dumping separate notes.

If your Codex runtime does not expose subagent tools, a valid fallback is for Codex to say that subagent tooling is unavailable, keep the same split inline, and synthesize the result itself.

## When To Use

Subagents are useful, but many Codex sessions still behave like one agent working through everything sequentially. That is fine for small tasks, but it is slow for work that naturally splits into independent lanes.

Typical split points include:

- Checking config, logs, history, and installed plugins in parallel.
- Comparing several tools, products, vendors, or documents.
- Investigating multiple unrelated test failures.
- Reviewing separate evidence lanes before a recommendation.
- Assigning implementation workers only when write scopes do not overlap.

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

## Examples

- See [examples/research.md](examples/research.md) for multi-source product or tool comparison.
- See [examples/debugging.md](examples/debugging.md) for config/log/history diagnosis.
- See [examples/coding.md](examples/coding.md) for independent coding failures and write-scope safety.
- See [docs/launch-checklist.md](docs/launch-checklist.md) for repository launch and promotion steps.

## Repository Layout

```text
.
|-- README.md
|-- README.zh-CN.md
|-- .github/workflows/check.yml
|-- .agents/plugins/marketplace.json
|-- plugins/subagent-dispatcher/
|   |-- .codex-plugin/plugin.json
|   `-- skills/subagent-dispatcher/
|       |-- SKILL.md
|       |-- agents/openai.yaml
|       `-- references/
|-- examples/
|-- docs/
|   `-- launch-checklist.md
`-- scripts/
    |-- check.ps1
    |-- install.ps1
    |-- install.sh
    `-- verify-install.ps1
```

## Validation

Run the lightweight repository check:

```powershell
.\scripts\check.ps1
```

This checks required files, manifest consistency, marketplace pointers, standing authorization documentation, one-line installer documentation, language-switch links, and common template leftovers.

The same check runs in GitHub Actions on pushes and pull requests.

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
