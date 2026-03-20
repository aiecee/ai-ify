---
name: buildify
description: Loads an implementation plan, reviews it critically, then executes each task (Red, Green, Refactor) with verification and per-task user feedback. Use when the user has a plan file and wants to build it.
---

# Buildify

Loads an implementation plan (`docs/plans/YYYY-MM-DD-<topic>.md`), reviews it critically, then executes each task in sequence—Red light, Green light, Refactor—with verification when specified and a feedback loop after each task. If the workspace is multi-root or the plan path is ambiguous, ask the user which plan file to use.

## Principles

- **Review the plan critically first** (Phase 1); do not start executing until questions and concerns are resolved.
- **Follow plan steps exactly**; do not skip or reorder unless the user explicitly asks.
- **Do not skip verifications**; if the plan specifies verification (e.g. run tests, run lint), run it and report output.
- **Reference skills when the plan says to** (e.g. if the plan mentions a skill or subagent, use it as specified).
- **Between tasks:** report what was done, then wait (e.g. for feedback or confirmation) before starting the next task.
- **Stop when blocked; do not guess**—ask for clarification.

## Phase 1: Load and review

1. Load the plan (user provides path or use e.g. `docs/plans/YYYY-MM-DD-<topic>.md` at repo root). Read the full file.
2. Review the plan **critically**. Identify questions (ambiguities, missing details) and concerns (risks, dependencies, order).
3. If there are questions or concerns: list them and ask the user. Wait for answers. Repeat until there are no unresolved questions or concerns.
4. When satisfied: create a **TodoWrite** with one todo per task (e.g. "Task 1: &lt;behaviour&gt;", "Task 2: …"). Do not create todos again later. Then continue to Phase 2.

## Phase 2: Execute

For **each task** in the plan (in order):

1. **Mark the task todo as in_progress.**
2. Follow the task's **Steps exactly**: execute **Red light** (create the listed tests; they should fail), then **Green light** (implement so tests pass), then **Refactor** (improve code, keep tests green). Create/Modify/Delete files as listed under **Files** when doing the steps.
3. If the plan specifies **verification** (e.g. "run tests", "run lint"), run it and capture output.
4. **Show what was implemented** (brief summary: files changed, main changes).
5. **Show verification output** (if any).
6. **Ask the user** if there is any feedback.
7. If the user gives feedback: apply the requested changes, then ask again for feedback. Repeat until the user has no further feedback (or confirms done).
8. **Mark the task todo as completed.** Report and wait before starting the next task.

When all tasks are completed, **summarise what was built** (brief overview: goal, tasks completed, main deliverables). Then stop.

## Rules

- Do not skip tasks or reorder them unless the user explicitly asks.
- Follow each task's Red / Green / Refactor steps in order; do not do Green before Red.
- One task at a time; complete the feedback loop before starting the next task.

## Stop immediately when

- A **blocker** occurs mid-task (e.g. missing dependency, test fails and cannot be resolved, instruction unclear).
- The **plan has critical gaps** that prevent starting (e.g. missing steps, contradictory instructions).
- **An instruction is unclear** and you would have to guess.
- **Verification fails repeatedly** and the cause is not obvious.

In any of these cases: **stop executing**, describe the issue clearly, and **ask for clarification**. Do not guess or proceed. Do not force through blockers—stop and ask.

## Return to Review (Phase 1) when

- The **user updates the plan** based on your feedback (reload the plan, review again, resolve any new questions, then continue from Phase 2).
- The **fundamental approach needs rethinking** (e.g. the plan is no longer viable; go back to Phase 1, review critically, and agree changes with the user before continuing).
