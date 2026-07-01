# Example: System Diagnosis

User request:

```text
Use subagent-dispatcher. Figure out why this Codex plugin is not being picked up. Split the work into independent read-only investigations.
```

Expected dispatch:

- Explorer 1: Inspect plugin manifest and required fields.
- Explorer 2: Inspect marketplace entry and plugin install status.
- Explorer 3: Inspect skill frontmatter and trigger wording.
- Explorer 4: Inspect recent logs, cache, or session state if available.

If subagent tooling is unavailable, Codex should state that and run the same four lanes inline before synthesizing.

Expected synthesis:

- State the most likely root cause.
- Show evidence for each lane.
- Identify any contradictions between manifest, marketplace, and installed cache.
- Recommend the smallest next action.

No worker should edit files until the likely fix area is known.
