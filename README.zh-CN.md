# subagent-dispatcher

[English](README.md) | [简体中文](README.zh-CN.md)

[![Repository check](https://github.com/sc543753481/codex-subagents-dispatcher/actions/workflows/check.yml/badge.svg)](https://github.com/sc543753481/codex-subagents-dispatcher/actions/workflows/check.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

帮助 Codex 在工作可以拆分时考虑使用子智能体。

## 为什么需要它

Codex 子智能体很强，但 Codex 通常需要明确授权和清晰的调度规则，才会稳定地使用它们。

`subagent-dispatcher` 给 Codex 提供一套可复用工作流：判断什么时候拆分、用几个智能体、每个智能体负责什么，以及主智能体如何综合结果。

它不会自动创建或启动子智能体。Codex 仍然需要运行在暴露子智能体工具的运行时中，而且当前 Codex 行为通常要求在生成子智能体前获得用户授权。这个插件补上的是工作流层。

## 安装

### 1. 推荐：直接让 Codex 安装

最方便的方式是把下面这段 prompt 交给 Codex，让它按当前环境可用的插件安装能力处理。这样你不用手动判断该走图形界面、CLI 还是备用安装器；Codex 也能保留同一组关键参数，并在安装后提醒你启用、验证、开启新线程。

```text
请帮我安装这个 Codex 插件。

plugin = subagent-dispatcher
marketplace = codex-subagents-dispatcher
source = https://github.com/sc543753481/codex-subagents-dispatcher.git
ref = main
after_install = enable, verify, then ask me to start a new thread

如果可以使用 Codex CLI：
1. 从 source URL 添加 marketplace。
2. 安装 subagent-dispatcher@codex-subagents-dispatcher。
3. 用 codex plugin list --json 验证。
4. 除非插件已经 installed 且 enabled，否则不要报告安装成功。
5. 如果我同意写入常驻指令，请加入本 README 里的 AGENTS.md 授权文本。
```

如果当前 Codex 环境不能直接管理插件，它应该明确说明限制，并引导你使用下面的手动图形界面或 CLI 路径。

为了让 Codex 在可拆分任务中主动考虑这个工作流，建议把下面的常驻授权指令加入用户级或项目级 `AGENTS.md`。带 `-Authorize` / `AUTHORIZE=1` 的安装器可以自动写入；图形界面和手动 CLI 通常不会自动写入。

```text
When a task can be split into independent workstreams, prefer the subagent-dispatcher workflow and use up to 5 subagents by default, up to 8 for read-only research. Before spawning subagents, briefly state the split, whether each agent is read-only or may edit files, and how results will be synthesized.
```

这很重要，因为 Codex 子智能体通常只会在用户明确授权子智能体或委派工作时才会生成。

### 2. Codex App 图形界面手动添加 marketplace

适合已经安装并登录 Codex app，且 app 提供 **Plugins** 图形界面的用户。

1. 打开 Codex app 的 **Plugins**。
2. 选择 **Add plugin marketplace**。
3. 只填写下面这些字段：

| 字段 | 填写内容 |
| --- | --- |
| Source | `https://github.com/sc543753481/codex-subagents-dispatcher.git` |
| Git ref | `main` |

重要：只填写上面列出的字段。这个仓库是 marketplace 仓库，Codex 需要读取根目录的 `.agents/plugins/marketplace.json`，以及该文件指向的插件目录。

如果你看到 `marketplace root does not contain a supported manifest`，请重新添加 marketplace，并且只填写 **Source** 和 **Git ref**；也可以使用下面的 CLI 备用方式。

4. 打开刚添加的插件市场 **Codex Subagents Dispatcher**。
5. 安装 **Subagent Dispatcher**。
6. 安装后打开一个新的 Codex 线程，让插件技能加载到会话中。

要确认安装结果，插件应该在 app 的插件列表中显示为已安装并启用。

深链接边界：下面的 Codex app 深链接只有在 Codex 已经知道 `codex-subagents-dispatcher` 这个 marketplace 之后才能打开安装流程。它不能替代“添加 marketplace”这一步。

```text
codex://plugins/install/subagent-dispatcher?marketplace=codex-subagents-dispatcher
```

### 3. 已验证 CLI 备用一行安装器

当 Plugins UI 不可用、你想要可复现命令，或者希望安装器自动写入全局 `AGENTS.md` 授权指令时，使用 CLI 备用方式。

要求：

- 已安装 Codex CLI。
- 已登录 Codex。

PowerShell，会同时写入全局 `AGENTS.md` 授权指令：

```powershell
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/sc543753481/codex-subagents-dispatcher/main/scripts/install.ps1))) -Ref main -Authorize
```

macOS/Linux 等价命令，会同时写入全局 `AGENTS.md` 授权指令：

```bash
curl -fsSL https://raw.githubusercontent.com/sc543753481/codex-subagents-dispatcher/main/scripts/install.sh | env REF=main AUTHORIZE=1 sh
```

安装后打开一个新的 Codex 线程，让插件技能加载到会话中。如果可以使用 Codex CLI，可以用下面命令验证安装：

```powershell
codex plugin list
```

你应该能看到 `subagent-dispatcher@codex-subagents-dispatcher` 显示为 `installed` 和 `enabled`。

### 4. 手动 CLI

不克隆仓库，直接从 GitHub 安装：

```powershell
codex plugin marketplace add sc543753481/codex-subagents-dispatcher --ref main
codex plugin add subagent-dispatcher@codex-subagents-dispatcher
```

手动 CLI 命令不会替你写入 `AGENTS.md`。如果希望 Codex 自动考虑这个工作流，请添加上面的授权指令。

### 5. 本地开发安装

在本仓库根目录中，运行本地安装脚本：

PowerShell:

```powershell
.\scripts\install.ps1 -Source . -Authorize
```

macOS/Linux:

```bash
env AUTHORIZE=1 sh ./scripts/install.sh .
```

### 6. 预览 / 验证

执行前预览远程安装器会运行哪些命令：

PowerShell:

```powershell
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/sc543753481/codex-subagents-dispatcher/main/scripts/install.ps1))) -DryRun
```

macOS/Linux:

```bash
curl -fsSL https://raw.githubusercontent.com/sc543753481/codex-subagents-dispatcher/main/scripts/install.sh | env DRY_RUN=1 sh
```

从克隆仓库中完成安装后，可以用下面命令验证：

```powershell
.\scripts\verify-install.ps1
```

也可以运行轻量级仓库检查，确认文档、清单、marketplace 指针和安装脚本引用仍然一致：

```powershell
.\scripts\check.ps1
```

仓库可以自动验证 CLI 行为，但不能自动点击 app 按钮。本次 README 更新中：

- 已验证：PowerShell 远程安装脚本带 `-Ref main -Authorize`，运行在临时 `CODEX_HOME` 中。
- 已验证：PowerShell 本地开发安装脚本带 `-Source . -Authorize`，运行在临时 `CODEX_HOME` 中。
- 已验证：`scripts/verify-install.ps1` 能确认两种临时安装结果。
- 已验证：`codex plugin marketplace add --help` 和 `codex plugin add --help` 与文档里的 CLI 参数一致。
- 当前未自动验证：Codex app 图形界面流程，以及 macOS/Linux shell 实际执行。

## 快速测试

安装后，在一个有多个独立区域可检查的项目里试试：

```text
Use subagent-dispatcher. Inspect this repository with read-only subagents: one for install flow, one for plugin manifest, one for examples/docs, and one for validation gaps. Synthesize the result into priorities.
```

预期行为：Codex 应该先说明拆分方式，让每个智能体保持聚焦，然后返回一个综合后的结论，而不是直接堆叠多个子智能体摘要。

如果你的 Codex 运行时没有暴露子智能体工具，合理的备用行为是 Codex 说明子智能体工具不可用，然后按同样的拆分方式在主线程内完成并综合结果。

## 适用场景

子智能体很有用，但很多 Codex 会话仍然像单个智能体一样按顺序处理所有事情。小任务这样做没有问题，但对天然可以拆成独立工作流的任务来说会变慢。

常见的拆分点包括：

- 并行检查配置、日志、历史记录和已安装插件。
- 比较多个工具、产品、供应商或文档。
- 调查多个互不相关的测试失败。
- 在给出建议前审查不同证据线。
- 仅在写入范围不重叠时分配实现 `worker`。

## 功能

- 判断一个任务是否值得拆分。
- 定义默认调度限制：常规最多 5 个子智能体，只读调研最多 8 个，代码编辑型 `worker` 最多 3 个。
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

## 示例

- 查看 [examples/research.md](examples/research.md)，了解多来源产品或工具比较。
- 查看 [examples/debugging.md](examples/debugging.md)，了解配置、日志和历史记录诊断。
- 查看 [examples/coding.md](examples/coding.md)，了解独立编码失败和写入范围安全。
- 查看 [docs/launch-checklist.md](docs/launch-checklist.md)，了解仓库发布和推广步骤。

## 仓库结构

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

## 校验

运行轻量级仓库检查：

```powershell
.\scripts\check.ps1
```

它会检查必需文件、清单一致性、插件市场指针、常驻授权指令文档、一行安装文档、语言切换链接和常见模板残留。

同一项检查也会在 GitHub Actions 中对 push 和 pull request 自动运行。

如果你的 Codex 环境提供 `plugin-creator` 和 `skill-creator` 校验器，也可以用它们进行 Codex 插件校验。

## 设计说明

这个设计刻意保持简单：

- 使用 Codex 技能，而不是 `MCP server`。
- 把调度规则保存在 Markdown 中，让 Codex 可以推理。
- 把示例和限制从主技能中拆出，以支持渐进式披露。
- 把子智能体结果当作需要审查的证据，而不是需要盲目信任的真相。

完整设计依据见 [docs/design.md](docs/design.md)。

## 许可证

MIT
