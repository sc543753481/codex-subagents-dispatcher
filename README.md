# subagent-dispatcher

Make Codex actually consider subagents when work can be split.

`subagent-dispatcher` is a general-purpose OpenAI Codex plugin that gives Codex standing authorization, dispatch rules, safety limits, and reusable prompts for using subagents on parallelizable work.

It is intentionally not a magic auto-spawn layer. Codex still needs a runtime that exposes subagent tools, and current Codex behavior expects user authorization before spawning subagents. This plugin supplies the missing workflow layer: when to split, how many agents to use, which roles to assign, and how the main agent should synthesize results.

## Why This Exists

Subagents are useful, but many Codex sessions still behave like one agent working through everything sequentially. That is fine for small tasks, but it is slow for work that naturally splits into independent lanes:

- Checking config, logs, history, and installed plugins in parallel.
- Comparing several tools, products, vendors, or documents.
- Investigating multiple unrelated test failures.
- Reviewing separate evidence lanes before a recommendation.
- Assigning implementation workers only when write scopes do not overlap.

This plugin nudges Codex into a better operating mode: main agent as dispatcher, subagents as focused workers, main agent as synthesizer.

## What It Does

- Decides whether a task is worth splitting.
- Defines default dispatch limits: 5 subagents normally, 8 for read-only research, 3 for code-editing workers.
- Separates `explorer`, `worker`, `reviewer`, and `synthesizer` style prompts.
- Covers coding and non-coding tasks.
- Requires the main agent to announce the split, set read/write boundaries, review outputs, and synthesize one coherent result.
- Documents when not to use subagents.

## What It Does Not Do

- It does not create Codex subagent tools by itself.
- It does not bypass Codex permissions or product limits.
- It does not guarantee every task gets faster.
- It does not make overlapping file edits safe.
- It does not install custom agents through `plugin.json`; current Codex plugin manifests do not provide that as a stable general mechanism.

## Repository Layout

```text
.
├── .agents/plugins/marketplace.json
├── plugins/subagent-dispatcher/
│   ├── .codex-plugin/plugin.json
│   └── skills/subagent-dispatcher/
│       ├── SKILL.md
│       ├── agents/openai.yaml
│       └── references/
├── examples/
├── docs/
└── scripts/check.ps1
```

## Installation

From this repository root, add its marketplace to Codex and install the plugin.

```powershell
codex plugin marketplace add .
codex plugin add subagent-dispatcher@codex-subagents-dispatcher
```

If your Codex build discovers local marketplace files differently, install from the marketplace name shown by:

```powershell
codex plugin list
```

Open a new Codex thread after installing so the plugin skill is loaded into the session.

## Recommended Standing Authorization

For best results, add this to your user or project `AGENTS.md`:

```text
When a task can be split into independent workstreams, prefer the subagent-dispatcher workflow and use up to 5 subagents by default, up to 8 for read-only research. Before spawning subagents, briefly state the split, whether each agent is read-only or may edit files, and how results will be synthesized.
```

This matters because Codex subagents are usually spawned only when the user has clearly authorized subagent or delegation work.

## Quick Test Prompt

After installing in a new thread, try:

```text
Use subagent-dispatcher. Inspect this project by splitting the work into read-only subagents: one for plugin manifest, one for skill trigger behavior, one for examples/docs, and one for validation gaps. Synthesize the result.
```

Expected behavior: Codex should explain the split before dispatching, keep agents focused, and merge their results instead of dumping separate summaries.

## Example Use Cases

- See [examples/research.md](examples/research.md) for multi-source product or tool comparison.
- See [examples/debugging.md](examples/debugging.md) for config/log/history diagnosis.
- See [examples/coding.md](examples/coding.md) for independent coding failures and write-scope safety.

## Validation

Run the lightweight repository check:

```powershell
.\scripts\check.ps1
```

This checks required files, manifest consistency, marketplace pointers, standing authorization documentation, and common template leftovers.

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
