# Decision Matrix

## Count Selection

Use 2 subagents when the task naturally has two independent lanes, such as config versus logs, frontend versus backend, or two candidate products.

Use 3 subagents when the task has three clear domains, such as code, tests, and docs; or current config, history, and runtime behavior.

Use 4-5 subagents for broad but bounded work, such as multiple independent failures, several documents, or a product comparison across sources.

Use 6-8 subagents only for read-only work where lanes are highly independent, such as scanning many documents, comparing many vendors, or gathering evidence from many sources.

Do not dispatch more than 3 code-editing workers in one batch.

## Role Selection

Choose `explorer` when the output should be facts, paths, citations, logs, risks, or a recommendation based on investigation.

Choose `worker` when the output should include direct file edits in a disjoint ownership area.

Use reviewer prompts when the output should challenge a result, check quality, validate requirements, or identify missing evidence.

## Dispatch Examples

Coding:
- Three unrelated failing test files: one worker per test file.
- Unknown root cause across config, runtime logs, and recent changes: three explorers first, then one worker if needed.
- Multi-file refactor with shared contracts: one explorer first, then sequential workers unless ownership is cleanly separated.

Research:
- Compare five tools: one explorer per tool, or one explorer per comparison axis if tools are too many.
- Analyze a market: one explorer for competitors, one for pricing, one for audience, one for risks.
- Review several documents: one explorer per document or section group, then main synthesis.

System diagnosis:
- Local app problem: one explorer for config, one for logs, one for running processes, one for recent state/history.
- Plugin issue: one explorer for manifest, one for marketplace/install state, one for skill trigger behavior.

## No-Dispatch Signals

Avoid subagents when:
- The task is a single direct answer.
- A single file or setting is obviously the center of the work.
- All lanes need the same scarce mutable resource.
- You cannot write a crisp one-paragraph prompt for each subagent.
- Results would be hard to integrate without redoing the work.
