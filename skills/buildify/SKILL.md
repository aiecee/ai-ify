---
name: buildify
description: Loads an implementation-ready plan, validates that each task is executable, then executes tasks in order using Red light, Green light, and Refactor with verification and per-task user feedback. Use when the user has a plan file and wants it implemented.
compatibility: 'Requires: filesystem access and ability to run project test/lint/build commands.'
---

# Buildify

Loads an implementation-ready plan (`docs/plans/YYYY-MM-DD-<topic>.md`), validates that the current task is executable, then executes tasks in sequence: Red light, Green light, Refactor, verification, feedback. Treat the plan as the source of truth for task order and scope. If the workspace is multi-root or the plan path is ambiguous, ask the user which plan file to use.

## Principles

- **Validate for execution, not critique**; do not redesign, improve, or reorder the plan during execution.
- **Treat the plan as the source of truth**; follow task order and scope exactly unless the user explicitly changes them.
- **Stay inside the current task's scope**; only change files and behaviour explicitly covered by the task's `Files`, `Red light`, `Green light`, and `Refactor` sections.
- **Use one task at a time**; complete the current task's implementation, verification, and feedback loop before moving to the next task.
- **Keep the task green throughout execution**; rerun the relevant task tests after the Green light pass and after the Refactor pass.
- **Do not skip verifications**; if the plan specifies verification (e.g. run tests, run lint), run it and report output.
- **Reference skills when the plan says to** (e.g. if the plan mentions a skill or subagent, use it as specified).
- **Stop when blocked; do not guess**—ask for clarification.
- **Do not expand scope opportunistically**; if a useful fix, cleanup, or adjacent change is not explicitly part of the current task, stop and ask instead of folding it in.

## Precedence

1. Higher-priority system, developer, and repo instructions override this skill.
2. The plan overrides default implementation choices where it is explicit.
3. Do not reinterpret the plan unless the current task is structurally invalid for execution.

## Phase 1: Load and validate

1. Load the plan (user provides path or use e.g. `docs/plans/YYYY-MM-DD-<topic>.md` at repo root). Read the full file.
2. Validate that the plan is execution-ready. A plan is execution-ready when:
   - tasks are ordered
   - each task has a clear behaviour-focused name
   - each task lists concrete files or clearly identified likely locations
   - each task includes `Red light`, `Green light`, and `Refactor`
   - broader verification is stated clearly when required
3. If the current task is structurally incomplete, internally contradictory, or would require guessing, stop and ask the user for clarification.
4. If the plan is execution-ready, create a task list with one entry per plan task (e.g. "Task 1: &lt;behaviour&gt;", "Task 2: …"). Use whatever task-tracking mechanism your environment supports. Do not create the task list again later.
5. Read **assets/validation-result-template.md** (relative to this skill). Use this template exactly as-is when reporting the validation result.
6. Then continue to Phase 2.

## Phase 2: Execute

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
3. Execute **Green light** once: implement only the smallest in-scope changes needed to make the Red light tests pass, then rerun the relevant task tests and confirm they pass.
4. Execute **Refactor** once: perform only the behaviour-preserving cleanup listed for the task, then rerun the relevant task tests to confirm the task stays green.
   - Only do an additional Refactor pass if a concrete, behaviour-preserving issue is still present and the extra work remains explicitly inside the task's scope.
5. Run any broader **verification** the plan specifies (e.g. "run tests", "run lint") and capture output. Even if the plan does not specify broader verification, do not skip the relevant task tests required by Red light, Green light, and Refactor.
6. Reconcile the completed work against the current task's bullets and listed files before reporting completion. If any necessary change is not covered by the task, stop and ask instead of adding it.
7. Read **assets/task-completion-template.md** (relative to this skill). Use this template exactly as-is when showing what was implemented.
8. Read **assets/verification-summary-template.md** (relative to this skill). Use this template exactly as-is when showing verification output.
9. Read **assets/feedback-checkpoint-template.md** (relative to this skill). Use this template exactly as-is when asking for feedback or confirming that you are waiting.
10. **Ask the user** if there is any feedback.
11. If the user gives feedback:

- **Feedback scope during buildify:**
  - In-scope feedback: implementation details, test clarity, code quality within the current task
  - Out-of-scope feedback: changes to the design, new requirements, reordering of tasks
  - If the user's feedback implies a design or plan change: stop, note that this would require updating the design doc or plan, and ask whether to pause buildify and address that first.
  - Do not absorb design changes inline; they should be documented before implementation continues.
- Apply the requested in-scope changes, rerun the affected task tests and any affected broader verification, then ask again for feedback. Repeat until the user has no further feedback (or confirms done).

12. **Mark the task todo as completed.**
13. Report and wait before starting the next task.

When all tasks are completed, **summarise what was built** (brief overview: goal, tasks completed, main deliverables). Then stop.

## Rules

- Do not skip tasks or reorder them unless the user explicitly asks.
- Follow each task's Red / Green / Refactor steps in order; do not do Green before Red.
- Stay within the current task's planned scope; do not add adjacent fixes, broader cleanup, or extra features unless the task explicitly calls for them.
- Default to one Green light pass and one Refactor pass.
- Rerun the relevant task tests after each Green light pass and after each Refactor pass.
- One task at a time; complete the feedback loop before starting the next task.
- Do not widen scope, combine tasks, or reinterpret the plan during execution.
- Do not treat useful adjacent cleanup as part of the task unless the task explicitly includes it.

## Stop immediately when

- A **blocker** occurs mid-task (e.g. missing dependency, test fails and cannot be resolved, instruction unclear).
- The **current task is not execution-ready** (e.g. missing required sections, contradictory instructions, or not enough detail to proceed without guessing).
- **An instruction is unclear** and you would have to guess.
- A change seems necessary or beneficial, but it is not explicitly covered by the current task.
- **Verification fails repeatedly** and the cause is not obvious.

In any of these cases: **stop executing**, describe the issue clearly, and **ask for clarification**. Do not guess or proceed. Do not force through blockers—stop and ask.

## Return to validation (Phase 1) when

- The **user updates the plan** based on your feedback (reload the plan, validate again, then continue from Phase 2).
- The **current task changes materially** and must be checked again for execution readiness before continuing.
