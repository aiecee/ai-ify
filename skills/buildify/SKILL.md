---
name: buildify
description: Loads an implementation plan, reviews it critically, then executes each task (Red, Green, Refactor) with verification and per-task user feedback. Use when the user has a plan file and wants to build it.
compatibility: 'Requires: git, filesystem access, ability to run project test/lint/build commands.'
---

# Buildify

Loads an implementation plan (`docs/plans/YYYY-MM-DD-<topic>.md`), reviews it critically, then executes each task in sequence—Red light, Green light, Refactor—with verification when specified and a feedback loop after each task. If the workspace is multi-root or the plan path is ambiguous, ask the user which plan file to use.

## Principles

- **Review the plan critically first** (Phase 1); do not start executing until questions and concerns are resolved.
- **Follow plan steps exactly**; do not skip or reorder unless the user explicitly asks.
- **Stay inside the current task's scope**; only change files and behaviour explicitly covered by the task's `Files`, `Red light`, `Green light`, and `Refactor` sections.
- **Keep the task green throughout the loop**; rerun the relevant task tests after each Green light pass and after each Refactor pass.
- **Do not skip verifications**; if the plan specifies verification (e.g. run tests, run lint), run it and report output.
- **Reference skills when the plan says to** (e.g. if the plan mentions a skill or subagent, use it as specified).
- **Between tasks:** report what was done, then wait (e.g. for feedback or confirmation) before starting the next task.
- **Stop when blocked; do not guess**—ask for clarification.
- **Do not expand scope opportunistically**; if a useful fix, cleanup, or adjacent change is not explicitly part of the current task, stop and ask instead of folding it in.
- **Commit only the current task's work**; if unrelated staged or unstaged changes are present when preparing the task commit, stop and ask instead of bundling them in.

## Phase 1: Load and review

1. Load the plan (user provides path or use e.g. `docs/plans/YYYY-MM-DD-<topic>.md` at repo root). Read the full file.
2. Review the plan **critically**. Identify questions (ambiguities, missing details) and concerns (risks, dependencies, order).
   - Use this checklist during the review:
     - Are the tasks ordered sensibly, with dependencies and foundations handled before dependent work?
     - Are the listed files concrete enough to execute without guesswork?
     - Are the Red light scenarios specific, testable, and clearly tied to behaviour rather than setup?
     - Does the plan's **Verification** section clearly state any broader checks that must be run?
     - Are scope boundaries clear, or do any tasks imply adjacent work that is not explicitly planned?
     - Are there missing dependencies, blockers, or assumptions that would prevent execution?
3. If there are questions or concerns: list them and ask the user. Wait for answers. Repeat until there are no unresolved questions or concerns.
4. When satisfied: create a task list with one entry per plan task (e.g. "Task 1: &lt;behaviour&gt;", "Task 2: …"). Use whatever task-tracking mechanism your environment supports (TodoWrite in Cursor, a checklist comment, or a local scratch file). Do not create the task list again later. Then continue to Phase 2.

## Phase 2: Execute

Before starting execution:

- **Branch check:** Confirm the current branch is appropriate for this work (i.e. not `main`/`master` directly, unless that is the team's convention).
- If on `main`/`master` and no feature branch exists, suggest creating one: `git checkout -b <topic-slug>`.
- Ask the user to confirm before proceeding if the branch situation is unclear.

For **each task** in the plan (in order):

1. **Mark the task todo as in_progress.**
2. Execute **Red light**: implement only the listed failing tests for the task.
   - **Red light confirmation:**
     - Run the tests and confirm they fail.
     - Verify the failure is a meaningful assertion failure (the behaviour is not yet implemented), **not** a setup error such as compile/import errors, missing mocks, or wrong test configuration.
     - If the test fails for a setup reason rather than a behaviour reason, fix the setup before proceeding. Do not count a setup failure as a valid Red.
   - **When Red light is impractical:**
     - If a behaviour cannot reasonably be specified as a failing test first (e.g. a visual UI state, an external webhook), note this explicitly and ask the user whether to:
       - Use a mock/stub to make it testable
       - Write the implementation first and add tests after (Green then Red, documented as an exception)
       - Skip automated testing for this specific behaviour and rely on manual verification
     - Do not silently skip Red; always surface the decision to the user.
3. Enter the **Green light / Refactor loop**:
   - **Green light:** implement only the smallest in-scope changes needed to make the Red light tests pass, then rerun the relevant task tests and confirm they pass before moving to Refactor.
   - **Refactor:** make behaviour-preserving cleanup only when it is justified by the current task, then rerun the relevant task tests to confirm the task stays green.
   - After each Refactor pass, re-check whether the task is still minimal, clear, and in scope. If further behaviour-preserving improvement is warranted, continue the Green light / Refactor loop. Stop the loop only when the task's listed tests pass, the implementation is minimal, and no further in-scope refactor would materially improve clarity, duplication, or structure without changing behaviour.
4. Run any broader **verification** the plan specifies (e.g. "run tests", "run lint") and capture output. Even if the plan does not specify broader verification, do not skip the relevant task tests required by the Green light / Refactor loop.
5. Reconcile the completed work against the current task's bullets and listed files before reporting completion. If any necessary change is not covered by the task, stop and ask instead of adding it.
6. **Show what was implemented** (brief summary: files changed, main changes).
7. **Show verification output** (if any).
8. **Ask the user** if there is any feedback.
9. If the user gives feedback:
   - **Feedback scope during buildify:**
     - In-scope feedback: implementation details, test clarity, code quality within the current task
     - Out-of-scope feedback: changes to the design, new requirements, reordering of tasks
     - If the user's feedback implies a design or plan change: stop, note that this would require updating the design doc or plan, and ask whether to pause buildify and address that first.
     - Do not absorb design changes inline; they should be documented before implementation continues.
   - Apply the requested in-scope changes, re-enter the Green light / Refactor loop as needed, rerun verification if affected, then ask again for feedback. Repeat until the user has no further feedback (or confirms done).
10. **Mark the task todo as completed.**
11. Ensure the pending commit contains only the current task's changes. If unrelated staged or unstaged changes are present, stop and ask before committing.
12. Create a git commit using the task behaviour name as the commit message. Use the behaviour text itself, not the `Task <number>:` prefix.
13. Report and wait before starting the next task.

When all tasks are completed, **summarise what was built** (brief overview: goal, tasks completed, main deliverables). Then stop.

## Rules

- Do not skip tasks or reorder them unless the user explicitly asks.
- Follow each task's Red / Green / Refactor steps in order; do not do Green before Red.
- Stay within the current task's planned scope; do not add adjacent fixes, broader cleanup, or extra features unless the task explicitly calls for them.
- Use a Green light / Refactor loop after Red light; do not stop at the first passing implementation if there is still in-scope, behaviour-preserving refactor to do.
- Rerun the relevant task tests after each Green light pass and after each Refactor pass.
- One task at a time; complete the feedback loop before starting the next task.
- Only create the git commit after the task has been marked completed.
- Only include current-task changes in the task commit; never sweep unrelated work into the commit.

## Stop immediately when

- A **blocker** occurs mid-task (e.g. missing dependency, test fails and cannot be resolved, instruction unclear).
- The **plan has critical gaps** that prevent starting (e.g. missing steps, contradictory instructions).
- **An instruction is unclear** and you would have to guess.
- A change seems necessary or beneficial, but it is not explicitly covered by the current task.
- Unrelated staged or unstaged changes are present when preparing the task commit.
- **Verification fails repeatedly** and the cause is not obvious.

In any of these cases: **stop executing**, describe the issue clearly, and **ask for clarification**. Do not guess or proceed. Do not force through blockers—stop and ask.

## Return to Review (Phase 1) when

- The **user updates the plan** based on your feedback (reload the plan, review again, resolve any new questions, then continue from Phase 2).
- The **fundamental approach needs rethinking** (e.g. the plan is no longer viable; go back to Phase 1, review critically, and agree changes with the user before continuing).
