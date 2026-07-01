# subagent-dispatcher

Make Codex actually consider subagents when work can be split.

让 Codex 在可拆分任务中主动考虑子智能体。

## Overview / 概览

`subagent-dispatcher` is a general-purpose OpenAI Codex plugin that gives Codex standing authorization, dispatch rules, safety limits, and reusable prompts for using subagents on parallelizable work.

`subagent-dispatcher` 是一个通用的 OpenAI Codex 插件，为 Codex 在可并行工作中使用子智能体提供常驻授权指令、调度规则、安全限制和可复用提示词。

It does not automatically create or start subagents. Codex still needs a runtime that exposes subagent tools, and current Codex behavior usually expects user authorization before spawning subagents. This plugin supplies the missing workflow layer: when to split, how many agents to use, which roles to assign, and how the main agent should synthesize results.

它不会自动创建或启动子智能体。Codex 仍然需要运行在暴露子智能体工具的运行时中，而且当前 Codex 行为通常要求在生成子智能体前获得用户授权。这个插件补上的是工作流层：什么时候拆分、使用多少个智能体、分配哪些角色，以及主智能体如何综合结果。

## Glossary / 术语表

| English | 中文 |
| --- | --- |
| `subagent` | 子智能体 |
| `subagent-dispatcher` | 保持插件名不变；可解释为子智能体调度器 |
| `agent` / `main agent` | 智能体 / 主智能体 |
| `standing authorization` | 常驻授权指令 |
| `independent workstreams` | 独立工作流 |
| `explorer` | `explorer`（探索者） |
| `worker` | `worker`（执行者） |
| `reviewer` | `reviewer`（审阅者） |
| `synthesizer` | `synthesizer`（综合者） |
| `write scope` | 写入范围 |
| `plugin manifest` | 插件清单文件 |

## Why This Exists / 为什么需要它

Subagents are useful, but many Codex sessions still behave like one agent working through everything sequentially. That is fine for small tasks, but it is slow for work that naturally splits into independent lanes.

子智能体很有用，但很多 Codex 会话仍然像单个智能体一样按顺序处理所有事情。小任务这样做没有问题，但对天然可以拆成独立工作流的任务来说会变慢。

Typical split points include:

常见的拆分点包括：

- Checking config, logs, history, and installed plugins in parallel. / 并行检查配置、日志、历史记录和已安装插件。
- Comparing several tools, products, vendors, or documents. / 比较多个工具、产品、供应商或文档。
- Investigating multiple unrelated test failures. / 调查多个互不相关的测试失败。
- Reviewing separate evidence lanes before a recommendation. / 在给出建议前审查不同证据线。
- Assigning implementation workers only when write scopes do not overlap. / 仅在写入范围不重叠时分配实现 worker。

This plugin guides Codex toward a better operating mode for parallel work: main agent as dispatcher, subagents as focused workers, main agent as synthesizer.

这个插件会引导 Codex 采用更适合并行任务的工作模式：主智能体负责调度，子智能体负责聚焦执行，主智能体负责综合结果。

## Capabilities and Limits / 功能与限制

What it does:

它做什么：

- Decides whether a task is worth splitting. / 判断一个任务是否值得拆分。
- Defines default dispatch limits: 5 subagents normally, 8 for read-only research, 3 for code-editing workers. / 定义默认调度限制：常规最多 5 个子智能体，只读调研最多 8 个，代码编辑型 worker 最多 3 个。
- Separates `explorer`, `worker`, `reviewer`, and `synthesizer` style prompts. / 区分 `explorer`、`worker`、`reviewer` 和 `synthesizer` 风格的提示词。
- Covers coding and non-coding tasks. / 覆盖编码任务和非编码任务。
- Requires the main agent to announce the split, set read/write boundaries, review outputs, and synthesize one coherent result. / 要求主智能体先说明拆分方式，设置读写边界，审查输出，并综合成一个连贯结果。
- Documents when not to use subagents. / 说明什么时候不该使用子智能体。

What it does not do:

它不做什么：

- It does not create Codex subagent tools by itself. / 它本身不会创建 Codex 子智能体工具。
- It does not bypass Codex permissions or product limits. / 它不会绕过 Codex 权限或产品限制。
- It does not guarantee every task gets faster. / 它不保证每个任务都会更快。
- It does not make overlapping file edits safe. / 它不会让重叠的文件编辑变得安全。
- It does not install custom agents through `plugin.json`; current Codex plugin manifests do not provide that as a stable general mechanism. / 它不会通过 `plugin.json` 安装自定义智能体；当前 Codex 插件清单文件还没有把这作为稳定的通用机制提供。

## Repository Layout / 仓库结构

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

## Installation / 安装

From this repository root, add its marketplace to Codex and install the plugin.

在本仓库根目录中，把它的插件市场加入 Codex，然后安装插件。

```powershell
codex plugin marketplace add .
codex plugin add subagent-dispatcher@codex-subagents-dispatcher
```

If your Codex build discovers local marketplace files differently, install from the marketplace name shown by:

如果你的 Codex 构建以不同方式发现本地插件市场文件，请使用下面命令显示的插件市场名称安装：

```powershell
codex plugin list
```

Open a new Codex thread after installing so the plugin skill is loaded into the session.

安装后打开一个新的 Codex 线程，让插件技能加载到会话中。

## AGENTS.md Authorization / AGENTS.md 常驻授权指令

For best results, add this to your user or project `AGENTS.md`:

为了获得更好的效果，把下面内容加入你的用户级或项目级 `AGENTS.md`：

```text
When a task can be split into independent workstreams, prefer the subagent-dispatcher workflow and use up to 5 subagents by default, up to 8 for read-only research. Before spawning subagents, briefly state the split, whether each agent is read-only or may edit files, and how results will be synthesized.
```

This matters because Codex subagents are usually spawned only when the user has clearly authorized subagent or delegation work.

这很重要，因为 Codex 子智能体通常只会在用户明确授权子智能体或委派工作时才会生成。

## Quick Test / 快速测试

After installing in a new thread, try:

在新线程中安装完成后，可以试试：

```text
Use subagent-dispatcher. Inspect this project by splitting the work into read-only subagents: one for plugin manifest, one for skill trigger behavior, one for examples/docs, and one for validation gaps. Synthesize the result.
```

Expected behavior: Codex should explain the split before dispatching, keep agents focused, and merge their results instead of directly listing separate subagent summaries.

预期行为：Codex 应该先说明拆分方式再进行调度，让智能体保持聚焦，并把结果合并起来，而不是直接罗列各子智能体摘要。

## Examples and Validation / 示例与校验

- See [examples/research.md](examples/research.md) for multi-source product or tool comparison. / 查看 [examples/research.md](examples/research.md)，了解多来源产品或工具比较。
- See [examples/debugging.md](examples/debugging.md) for config/log/history diagnosis. / 查看 [examples/debugging.md](examples/debugging.md)，了解配置、日志和历史记录诊断。
- See [examples/coding.md](examples/coding.md) for independent coding failures and write-scope safety. / 查看 [examples/coding.md](examples/coding.md)，了解独立编码失败和写入范围安全。

Run the lightweight repository check:

运行轻量级仓库检查：

```powershell
.\scripts\check.ps1
```

This checks required files, manifest consistency, marketplace pointers, standing authorization documentation, and common template leftovers.

它会检查必需文件、清单一致性、插件市场指针、常驻授权指令文档和常见模板残留。

For Codex plugin validation, use the `plugin-creator` and `skill-creator` validators from your Codex environment if available.

如果你的 Codex 环境提供 `plugin-creator` 和 `skill-creator` 校验器，也可以用它们进行 Codex 插件校验。

## Design Notes / 设计说明

The design is intentionally simple:

这个设计刻意保持简单：

- Use a Codex skill, not an MCP server. / 使用 Codex 技能，而不是 MCP server。
- Keep the dispatch rules in Markdown so Codex can reason about them. / 把调度规则保存在 Markdown 中，让 Codex 可以推理。
- Keep examples and limits separate from the main skill for progressive disclosure. / 把示例和限制从主技能中拆出，以支持渐进式披露。
- Treat subagent results as evidence to review, not truth to blindly trust. / 把子智能体结果当作需要审查的证据，而不是需要盲目信任的真相。

See [docs/design.md](docs/design.md) for the full design rationale.

完整设计依据见 [docs/design.md](docs/design.md)。

## License / 许可证

MIT
