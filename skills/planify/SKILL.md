---
name: planify
description: Turns specs, requirements, or design docs into an implementation plan—tasks by behaviour, red-green-refactor per task, output to docs/plans/. Use when the user has a spec or design and wants an implementation plan.
compatibility: 'Requires: git, filesystem access, ability to run project test/lint/build commands.'
---

# Planify

Turns a spec, requirements doc, or design document into an implementation plan. Split work into **vertical tasks by behaviour**; each task has Red light, Green light, and Refactor steps. Output is a single markdown file at `docs/plans/YYYY-MM-DD-<topic>.md` (one header + list of tasks). Do not reference other skills; red-green-refactor is defined below.

## Red / Green / Refactor (per task)

- **Red light:** Implement failing tests for this task’s behaviour(s) following the **Given / When / Then** principle.
- **Green light:** Minimal implementation to make those tests pass. List the implementation details.
- **Refactor:** Improve the code while keeping tests green.

Tasks are vertical slices: each task groups related behaviour and gets its own Red / Green / Refactor steps. The Red light phase is where the actual test code is written.

## Given / When / Then (GWT)

Tests should be structured as behaviour-oriented scenarios:

- **Given:** The initial state or context.
- **When:** The action or event being tested.
- **Then:** The expected outcome or assertion.

## Workflow

1. **Input.** User provides or points to a spec, requirements doc, or design document.

2. **Parse, scope, and ground the plan in the repo.**
   - Read the input doc and identify the feature or scope to implement.
   - Before choosing file paths, test locations, or verification commands, inspect the current repo context.
   - Priority context to check:
     - `README.md` or `README.*`
     - `docs/`, `planning/`, and existing files in `docs/plans/`
     - `package.json`, `pyproject.toml`, or equivalent project manifests
     - Relevant source and test directories for the area being planned
     - Recent history such as `git log -10 --oneline`
   - Use that repo context to ground the plan's file paths, test locations, and verification steps. If exact locations are still unclear, say so explicitly rather than inventing precision.

3. **Split into tasks (vertical by behaviour).** Group **related behaviours** into tasks. Each task is one vertical slice (e.g. Task 1: Auth validation, Task 2: Cart persistence). Do not put unrelated behaviours in the same task; do not create a single giant task. One or more related behaviours per task; each task is a planned unit of work.
   - After splitting tasks, identify dependencies between them:
     - Which tasks must be completed before others can start?
     - Are there shared foundations (e.g. a data model, an auth layer) that multiple tasks rely on?
     - Order tasks so that foundational work comes first.
     - Add a one-sentence sequencing rationale to the plan header's Approach section.

4. **Build the plan.**
   - Read **assets/plan-header-template.md** (relative to this skill). Fill the title, the exact `Design doc` path, Goal (1-3 sentences from the spec), Approach (2-4 sentences), Coverage note, and Verification section.
   - If broader verification beyond the task-level Red / Green / Refactor loop is needed (for example full test suite, lint, type-check, build, or manual checks), document it in the plan header's **Verification** section so execution has explicit instructions to follow.
   - For each task, read **assets/task-structure-template.md** and fill it with implementation-ready detail:
     - **Task heading:** Use a behaviour-focused name that states the outcome for this slice.
     - **Files (Create / Modify / Delete):**
       - List concrete relative file paths whenever possible (not vague labels like "backend files").
       - Group every file under Create, Modify, or Delete; use "none" only when that bucket is truly empty.
       - If exact paths are unknown, provide the most likely location plus a short note (for example, "likely in auth middleware area").
     - **Red light (tests first):**
       - List the failing tests to implement for this task's behaviours using the **Given / When / Then** structure.
       - Aim for the minimum number of tests that would catch a wrong implementation:
         - At least one happy path scenario per behaviour
         - Edge and error cases only when the behaviour has meaningful boundary conditions
         - Do not add tests purely for coverage; each scenario should be independently motivatable
       - Test level selection:
         - Unit: behaviour is isolated to a single function, class, or module with no external I/O
         - Integration: behaviour involves multiple modules working together, or touches a database/API boundary
         - E2E: behaviour is a full user-visible flow through the system
         - When in doubt, prefer the lowest level that gives confident coverage of the behaviour
         - Note the chosen test level in the task's Red light section
       - Mention the chosen test level in the task's Red light section and include one or more explicit Given / When / Then scenarios.
       - Mention likely test location when it is inferable from the spec/repo.
       - Use specific outcomes/assertions (what should fail before implementation), not generic bullets like "add tests".
     - **Green light (minimal implementation):**
       - List the smallest concrete code changes needed to make the Red tests pass.
       - Name the important modules, components, handlers, schemas, state updates, or data-flow touchpoints involved.
       - Keep bullets sequential, concrete, and action-oriented so someone can execute them directly without widening scope.
       - Prefer explicit implementation touchpoints over vague instructions such as "wire it up" or "update logic."
     - **Refactor (after green):**
       - List scoped cleanup that preserves behaviour (for example: extract helper, remove duplication, improve naming, simplify branching).
       - Keep refactor items tightly tied to the task's implementation and distinguish them from new behaviour or adjacent improvements.
       - Do not introduce new features or expand scope during Refactor.
   - Quality bar: each task should be actionable on its own and avoid placeholders such as "implement logic" or "update as needed."
   - Combine into one document: one header (from plan-header-template) then Task 1, Task 2, ... (each from task-structure-template).

5. **Coverage check (before writing output).**
   - List the success criteria and testing scenarios from the design doc.
   - For each criterion, confirm it is addressed by at least one task's Red light scenarios.
   - If any criterion has no corresponding test scenario in the plan, flag it and resolve before writing the output file.
   - Add a short "Coverage" note at the top of the plan header confirming this check was done.

6. **Output.** Write the combined plan to **docs/plans/YYYY-MM-DD-<topic>.md** at the project/repo root (topic = short slug, e.g. `auth-validation`, `cart-persistence`). Create **docs/plans/** if it does not exist. If the workspace has no single obvious repo root, use the repo that contains the code being planned, or ask the user where to save.
   - If the design doc contains an `Implementation plan` field, update it to point to the new plan path when your environment and workflow allow editing the design doc as part of this step. Otherwise, tell the user the exact path to add.
