# Example: Independent Coding Failures

User request:

```text
Use subagent-dispatcher. Three unrelated test files are failing. Investigate and fix them in parallel if write scopes do not overlap.
```

Expected first step:

- Main agent groups failures by test file, subsystem, and likely ownership.
- Main agent checks whether write scopes overlap.

Safe dispatch:

- Worker 1: Own failing tests and implementation for subsystem A.
- Worker 2: Own failing tests and implementation for subsystem B.
- Worker 3: Own failing tests and implementation for subsystem C.

Unsafe dispatch:

- Do not dispatch three workers if all failures point at the same shared parser, database migration, or config loader.

Expected synthesis:

- Review each worker's changed files.
- Check for conflicts.
- Run the full relevant test suite.
- Report what changed and what verification passed.
