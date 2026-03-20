---
name: verifyify
description: Verifies implementation against a design doc and plan—compares changes to plan/design for completion, runs tests and verifications (compile, lint), and does a light code review for polish. Use when the user has a design doc and plan and wants to verify completion before human code review.
compatibility: 'Requires: git, filesystem access, ability to run project test/lint/build commands.'
---

# Verifyify

Consumes a **design doc** and an **implementation plan**, compares the current codebase (or changes) against both to assess completion, runs tests and verifications so everything compiles and is compliant, and does a **light code review** to surface polish before a human does a full code review.

## Inputs

- **Design doc:** path to the design document (e.g. `docs/plans/YYYY-MM-DD-<topic>-design.md`). User may provide or infer from topic.
- **Plan:** path to the implementation plan (e.g. `docs/plans/YYYY-MM-DD-<topic>.md`). User may provide or infer.
- If the workspace is multi-root or paths are ambiguous, ask the user which design doc and plan to use.

## Workflow

**Step 1: Load design doc and plan**

- Read both files fully. Summarise briefly: goal of the design, the list of tasks from the plan (Task 1: …, Task 2: …, etc.), and any explicit items listed in the plan's **Verification** section.

**Step 2: Determine what has changed**

- Ask the user to confirm the correct base branch or commit to diff against (e.g. `main`, `develop`, a specific SHA).
- Default suggestion: `git diff main..HEAD` if a feature branch workflow is used.
- Do not assume the baseline; an incorrect diff means verifyify is checking the wrong work.
- Use e.g. `git status`, `git diff`, and the confirmed baseline diff to identify changed files and scope. Optionally list new/modified/deleted files. This is the implementation to verify.

**Step 3: Compare to plan and design (completion check)**

- For each **plan task** (Task 1, Task 2, …): check whether the changes address the task (behaviour, files, steps). Mark as done, partial, or not done. Note any plan items with no corresponding changes.
- Flag changed files that fall outside the plan task's listed `Files` buckets as a potential scope drift that must be called out.
- Ensure that implemented tests follow the **Given / When / Then** scenarios defined in the plan.
- **GWT scenario coverage check:**
  - For each task in the plan, list the specific Given / When / Then scenarios defined in the Red light section.
  - For each scenario, confirm a corresponding test exists in the codebase.
  - Mark each scenario as covered, partially covered, or missing.
  - Report missing scenarios as completion gaps, not polish items.
- Distinguish planned behaviour-preserving refactor from unplanned new behaviour or adjacent changes; report extra unplanned work as a completion gap or scope deviation, not just a polish note.
- For the **design doc** (sections such as architecture, components, data flow, error handling, testing): check whether the implementation aligns. Note gaps (e.g. "design called for X; no evidence in changes").
- Produce a short **completion report**: plan tasks (done/partial/not done), scope drift (none/noted), design alignment (met/gaps). Do not guess; if unclear, say "unclear — needs manual check."

**Step 4: Run tests and verifications**

- Read the plan's **Verification** section and treat it as required verification scope unless the user explicitly says otherwise.
- Run each verification item listed in the plan's **Verification** section, or explicitly report why a specific item could not be run.
- Run whatever the project uses to verify build and compliance: e.g. `pnpm test`, `pnpm lint`, `pnpm check-types` or `tsc`, `pnpm build` (or project-equivalent). Capture exit codes and relevant output (failures, error summaries).
- **Regression check:**
  - Run the full test suite (not just the tests added in this feature).
  - Confirm that tests passing before this feature are still passing.
  - Report any pre-existing test failures separately from new test failures; do not conflate them.
- Report: **Plan verification items:** completed / skipped / failed (with notes). **Compiles / type-check:** pass or fail (and summary). **Lint:** pass or fail (and summary). **Tests:** pass or fail (and summary). If the project has a single "verify" or "pr" script, run that and report.

**Step 5: Light code review (polish)**

- Review the **changed code** (diffs or key files) at a high level only. Look for obvious polish: dead code, duplicated logic, naming, missing error handling, inconsistent style, comments that say "TODO" or "hack." Do **not** do a full code review (no deep security, no full style guide). Goal: surface a short list of **polish suggestions** that could be fixed before a human reviews.
- Output: bullet list of polish items (file/area + brief suggestion). Keep scope drift or unplanned behaviour findings in the completion report, not in polish. If nothing obvious, say "No polish items identified."

**Step 6: Summary and next steps**

- Produce the verification summary: (1) completion vs plan and design, (2) test/verification results, (3) polish suggestions.
- Include whether the plan's explicit **Verification** section was fully satisfied, partially satisfied, or blocked.
- Then provide explicit next step guidance:
  - If there are completion gaps or test failures: "Return to buildify with the specific tasks that need work: [list them]. Address gaps before re-running verifyify."
  - If there is only polish: "Implementation is complete. The following polish items are optional but recommended before human review: [list them]."
  - If everything passes: "Verification complete. This is ready for human code review."

## Rules

- Do not claim completion if plan or design has unmet items unless the user has explicitly said they are out of scope.
- Do not treat out-of-scope file changes or unplanned behaviour as completed work; report them clearly as scope deviations.
- If tests or build fail, report them clearly; do not suggest "verification passed" for the failing step.
- Keep the code review step light and explicitly "pre–human review polish" only.
