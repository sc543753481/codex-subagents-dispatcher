# Limits And Safety

## Default Limits

Default maximum per dispatch batch: 5 subagents.

Read-only soft maximum: 8 subagents. Use this only for independent evidence gathering, document review, or broad comparisons.

Code-editing maximum: 3 worker subagents. Each worker must have a disjoint write scope.

Reviewer maximum: 2 reviewer subagents. More reviewers usually add noise instead of clarity.

## Escalation Rules

Before exceeding 5 subagents, confirm that:
- Every lane is independent.
- The main agent can synthesize all results.
- Most or all work is read-only.
- The task is large enough that parallelism pays for coordination cost.

For more than 8 lanes, batch the work. Dispatch the first batch, synthesize, then decide whether more agents are still useful.

## Model And Reasoning Defaults

Default to inheriting the main agent's model and reasoning effort.

Use lower reasoning only for bounded read-only exploration, simple file lookup, config listing, and first-pass source gathering.

Use the main agent's reasoning level or higher for synthesis, code review, architecture, high-risk changes, security-sensitive work, and tasks where a wrong conclusion would be expensive.

Do not override a subagent model or reasoning effort unless the user requests it or the task has a clear reason.

## Write Safety

For workers that edit files:
- Assign exact files or modules.
- Tell workers not to revert unrelated edits.
- Avoid overlapping ownership.
- Prefer one worker plus one reviewer when overlap is likely.
- Run final verification in the main agent after integration.

## Result Safety

Do not treat subagent output as automatically true. The main agent must:
- Check evidence quality.
- Notice contradictions.
- Re-run critical verification when practical.
- State uncertainty when evidence is partial.
- Close completed agents when they are no longer needed.
