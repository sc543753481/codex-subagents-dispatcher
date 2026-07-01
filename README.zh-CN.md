# subagent-dispatcher

[English](README.md) | [简体中文](README.zh-CN.md)

让 Codex 在可拆分任务中主动考虑子智能体。

## 安装

优先推荐：从 Codex app 图形界面安装。

1. 打开 Codex app 的 **Plugins**。
2. 选择 **Add plugin marketplace**。
3. 填写：

```text
Source: sc543753481/codex-subagents-dispatcher
Git ref: main
Sparse path: leave empty
```

4. 打开新增的 marketplace，安装 **Subagent Dispatcher**。
5. 安装后打开一个新的 Codex 线程，让插件技能加载到会话中。

Codex app 深链接只能在 Codex 已经知道该插件市场之后打开安装流程：

```text
codex://plugins/install/subagent-dispatcher?marketplace=codex-subagents-dispatcher
```

首次公开安装，请先用上面的图形界面添加 marketplace；也可以使用安装脚本，或使用下面的 Codex CLI 命令。

### CLI 安装

需要先安装 Codex CLI 并完成登录。

PowerShell 一行安装：

```powershell
irm https://raw.githubusercontent.com/sc543753481/codex-subagents-dispatcher/main/scripts/install.ps1 | iex
```

推荐的 PowerShell 安装方式，会同时写入全局 `AGENTS.md` 授权指令：

```powershell
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/sc543753481/codex-subagents-dispatcher/main/scripts/install.ps1))) -Authorize
```

macOS/Linux:

```bash
curl -fsSL https://raw.githubusercontent.com/sc543753481/codex-subagents-dispatcher/main/scripts/install.sh | sh
```

推荐的 macOS/Linux 安装方式，会同时写入全局 `AGENTS.md` 授权指令：

```bash
curl -fsSL https://raw.githubusercontent.com/sc543753481/codex-subagents-dispatcher/main/scripts/install.sh | env AUTHORIZE=1 sh
```

执行前想先预览命令：

```powershell
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/sc543753481/codex-subagents-dispatcher/main/scripts/install.ps1))) -DryRun
```

```bash
curl -fsSL https://raw.githubusercontent.com/sc543753481/codex-subagents-dispatcher/main/scripts/install.sh | env DRY_RUN=1 sh
```

## 概览

`subagent-dispatcher` 是一个通用的 OpenAI Codex 插件，为 Codex 在可并行工作中使用子智能体提供常驻授权指令、调度规则、安全限制和可复用提示词。

它不会自动创建或启动子智能体。Codex 仍然需要运行在暴露子智能体工具的运行时中，而且当前 Codex 行为通常要求在生成子智能体前获得用户授权。这个插件补上的是工作流层：什么时候拆分、使用多少个智能体、分配哪些角色，以及主智能体如何综合结果。

## 适用场景

子智能体很有用，但很多 Codex 会话仍然像单个智能体一样按顺序处理所有事情。小任务这样做没有问题，但对天然可以拆成独立工作流的任务来说会变慢。

常见的拆分点包括：

- 并行检查配置、日志、历史记录和已安装插件。
- 比较多个工具、产品、供应商或文档。
- 调查多个互不相关的测试失败。
- 在给出建议前审查不同证据线。
- 仅在写入范围不重叠时分配实现 worker。

这个插件会引导 Codex 采用更适合并行任务的工作模式：主智能体负责调度，子智能体负责聚焦执行，主智能体负责综合结果。

## 功能

- 判断一个任务是否值得拆分。
- 定义默认调度限制：常规最多 5 个子智能体，只读调研最多 8 个，代码编辑型 worker 最多 3 个。
- 区分 `explorer`、`worker`、`reviewer` 和 `synthesizer` 风格的提示词。
- 覆盖编码任务和非编码任务。
- 要求主智能体先说明拆分方式，设置读写边界，审查输出，并综合成一个连贯结果。
- 说明什么时候不该使用子智能体。

## 限制 / 非目标

- 它本身不会创建 Codex 子智能体工具。
- 它不会绕过 Codex 权限或产品限制。
- 它不保证每个任务都会更快。
- 它不会让重叠的文件编辑变得安全。
- 它不会通过 `plugin.json` 安装自定义智能体；当前 Codex 插件清单文件还没有把这作为稳定的通用机制提供。

## 仓库结构

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

## 安装

在本仓库根目录中，运行本地安装脚本：

PowerShell:

```powershell
.\scripts\install.ps1
```

macOS/Linux:

```bash
sh ./scripts/install.sh
```

安装脚本会替你运行下面这些官方 Codex CLI 命令：

```powershell
codex plugin marketplace add .
codex plugin add subagent-dispatcher@codex-subagents-dispatcher
```

如果你的 Codex 构建以不同方式发现本地插件市场文件，请使用下面命令显示的插件市场名称安装：

```powershell
codex plugin list
```

也可以不克隆仓库，直接从 GitHub 安装：

```powershell
codex plugin marketplace add sc543753481/codex-subagents-dispatcher --ref main
codex plugin add subagent-dispatcher@codex-subagents-dispatcher
```

运行安装脚本后，可以用下面命令验证本地安装：

```powershell
.\scripts\verify-install.ps1
```

## AGENTS.md 常驻授权指令

为了获得更好的效果，把下面内容加入你的用户级或项目级 `AGENTS.md`：

```text
When a task can be split into independent workstreams, prefer the subagent-dispatcher workflow and use up to 5 subagents by default, up to 8 for read-only research. Before spawning subagents, briefly state the split, whether each agent is read-only or may edit files, and how results will be synthesized.
```

这很重要，因为 Codex 子智能体通常只会在用户明确授权子智能体或委派工作时才会生成。

安装脚本可以通过 PowerShell 的 `-Authorize` 或 macOS/Linux 的 `AUTHORIZE=1` 自动写入全局 Codex 指令。

## 快速测试

在新线程中安装完成后，可以试试：

```text
Use subagent-dispatcher. Inspect this project by splitting the work into read-only subagents: one for plugin manifest, one for skill trigger behavior, one for examples/docs, and one for validation gaps. Synthesize the result.
```

预期行为：Codex 应该先说明拆分方式再进行调度，让智能体保持聚焦，并把结果合并起来，而不是直接罗列各子智能体摘要。

如果你的 Codex 运行时没有暴露子智能体工具，合理的 fallback 是 Codex 说明子智能体工具不可用，然后按同样的拆分方式在主线程内完成并综合结果。

## 示例

- 查看 [examples/research.md](examples/research.md)，了解多来源产品或工具比较。
- 查看 [examples/debugging.md](examples/debugging.md)，了解配置、日志和历史记录诊断。
- 查看 [examples/coding.md](examples/coding.md)，了解独立编码失败和写入范围安全。

## 校验

运行轻量级仓库检查：

```powershell
.\scripts\check.ps1
```

它会检查必需文件、清单一致性、插件市场指针、常驻授权指令文档、一行安装文档、语言切换链接和常见模板残留。

验证 Codex 能否看到已安装插件：

```powershell
.\scripts\verify-install.ps1
```

如果你的 Codex 环境提供 `plugin-creator` 和 `skill-creator` 校验器，也可以用它们进行 Codex 插件校验。

## 设计说明

这个设计刻意保持简单：

- 使用 Codex 技能，而不是 MCP server。
- 把调度规则保存在 Markdown 中，让 Codex 可以推理。
- 把示例和限制从主技能中拆出，以支持渐进式披露。
- 把子智能体结果当作需要审查的证据，而不是需要盲目信任的真相。

完整设计依据见 [docs/design.md](docs/design.md)。

## 许可证

MIT
