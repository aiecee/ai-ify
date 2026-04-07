---
name: cardify
description: Transforms a planify-generated plan into Kanban cards—one card per task, each with Red/Green/Refactor flow, linked in dependency order. Use when the user has a plan and wants to create trackable Kanban cards for each task.
compatibility: 'Requires: Kanban CLI (`kanban`), git, filesystem access, ability to read plan files from docs/plans/.'
---

# Cardify

Transforms a planify-generated implementation plan into a set of Kanban cards—one card per task—ready for tracking and execution. Each card includes the Red light, Green light, Refactor workflow from buildify, and cards are linked in dependency order to match the plan's task sequence.

## CRITICAL: Use the Kanban CLI

**You MUST use the `kanban` CLI to create all cards. Do NOT create markdown files manually.**

- The `kanban` CLI should be available in PATH (use `kanban` command).
- Use `kanban task create --project-path "<project-path>" --prompt "<content>"` to create each card.
- Use `kanban task link --project-path "<project-path>" --task-id <task-id> --linked-task-id <linked-task-id>` to create dependencies.
- **NEVER** create `.md` files as a substitute for Kanban cards.
- **NEVER** invent your own card format—follow the template strictly.

## Principles

- **One card per task**: Each task in the plan becomes its own Kanban card; do not merge or split tasks.
- **Preserve plan order**: Cards are created in the same order as tasks appear in the plan, forming a dependency chain.
- **Include full R/G/R flow**: Every card contains the Red light, Green light, Refactor steps from the plan, formatted for execution.
- **Link cards sequentially**: Each newly created card links to the previously created card, establishing a clear dependency chain.
- **Resolve the Kanban project path once**: Compute the canonical repo checkout path once per run and reuse it for every `kanban` command.
- **Ground cards in the template**: Use the task-template.md to ensure consistent card structure across all tasks.
- **Reference the source plan**: Every card includes a link back to the original planify-generated plan.

## Workflow

### 1. Load the plan

- User provides the path to a planify-generated plan (e.g. `docs/plans/YYYY-MM-DD-<topic>.md`), or the skill infers it from context.
- Read the full plan file.
- Verify it is a valid planify output (has a header section followed by numbered tasks with Red light, Green light, Refactor sections).
- If the file is not a valid plan or cannot be parsed, stop and ask the user for clarification.

### 2. Parse tasks from the plan

- Extract each task from the plan:
  - Task number (e.g., "Task 1", "Task 2")
  - Task name/behavior (the task heading)
  - Files (Create/Modify/Delete lists)
  - Red light scenarios (Given/When/Then)
  - Green light steps
  - Refactor items
  - Any verification notes
- Count the total number of tasks to create.

### 3. Read the task template

**MANDATORY**: Read `skills/cardify/assets/task-template.md` before creating any cards. This template defines the required structure for every Kanban card.

- Read `assets/task-template.md` (relative to this skill directory).
- Use this template exactly as-is for all card content. Do not modify the structure.

### 4. Resolve the Kanban project path

**IMPORTANT**: Resolve the canonical repo checkout path before creating any cards. This is the shared Kanban `--project-path` for the entire run.

- From the workspace root, execute: `PROJECT_PATH="$(sh skills/cardify/scripts/resolve-project-path.sh)"`
- Reuse `"$PROJECT_PATH"` for every `kanban` command in this run.
- Do **NOT** use `git rev-parse --show-toplevel` when you need the shared board. In a linked worktree, that returns the worktree checkout path, which would create cards in the wrong Kanban project.
- If the script fails, or if the resolved path points at the active worktree instead of the canonical repo checkout, stop and report the problem before creating any cards.

### 5. Create Kanban cards (in plan order)

**IMPORTANT**: Every `kanban` command in this section must include `--project-path "$PROJECT_PATH"`.

For **each task** in the plan, in order:

1. **Create a new Kanban card** using the task template:
   - Execute: `kanban task create --project-path "$PROJECT_PATH" --prompt "<card content>"`
   - Fill in the card content using `skills/cardify/assets/task-template.md` exactly. Replace the template placeholders with the corresponding values from the task in the plan.

2. **Link to the previous card** (dependency chain):
   - For Task 1: No dependency needed (first task).
   - For Task 2 and beyond: Execute `kanban task link --project-path "$PROJECT_PATH" --task-id <current-task-id> --linked-task-id <previous-task-id>`
   - The current task depends on the previous task in the chain.

3. **Record the card reference**:
   - Store the card ID returned by `kanban task create` for use in linking the next card.

4. **Confirm card creation** before proceeding to the next task.

### 6. Confirm dependency chain and verify project path

After all cards are created:

- Confirm `"$PROJECT_PATH"` is the canonical repo checkout path, not the active linked worktree path.
- Do not recompute the path during verification. The same `"$PROJECT_PATH"` value must be reused for create, link, and list operations.
- List all cards in order with their dependencies:
  - Task 1: (no dependency)
  - Task 2: depends on Task 1
  - Task 3: depends on Task 2
  - ... and so on
- Use `kanban task list --project-path "$PROJECT_PATH"` if you need to inspect the created cards.
- Verify the chain matches the plan's task order.
- Report the total number of cards created and the dependency chain structure.

### 7. Summary

- Report completion: number of cards created, plan source, and dependency chain.
- Remind the user that each card can be executed using the buildify skill.

## Rules

- **MANDATORY: Use the `kanban` CLI** for all card operations. Do NOT create markdown files manually.
- **MANDATORY: Use the template** from `skills/cardify/assets/task-template.md` for all card content. Do NOT invent your own format.
- Resolve `PROJECT_PATH` once with `sh skills/cardify/scripts/resolve-project-path.sh` and reuse it for every `kanban` command in the run.
- Every `kanban` command must include `--project-path "$PROJECT_PATH"`.
- Create cards in the exact order tasks appear in the plan; do not reorder.
- Do not merge multiple tasks into one card; one task = one card.
- Do not split a single task into multiple cards.
- Every card must include the Red light, Green light, Refactor sections from the plan.
- Every card (except the first) must link to the previous card as a dependency using `kanban task link --task-id <current-task-id> --linked-task-id <previous-task-id>`.
- Do not use the active worktree root or `git rev-parse --show-toplevel` when the goal is the shared canonical Kanban board.
- If the plan has no tasks, stop and report that there is nothing to cardify.
- If a task is missing required sections (e.g., no Red light), note it but create the card with available content.
- If project-path resolution fails, stop and report the issue rather than creating cards in the wrong board.

## Stop immediately when

- The provided file is not a valid planify-generated plan.
- The plan cannot be parsed (missing structure, corrupted format).
- The Kanban project path cannot be resolved to the canonical repo checkout.
- The Kanban system is unavailable or card creation fails.
- A task cannot be mapped to a card due to missing essential information.
- The user interrupts or requests changes mid-workflow.

## Inputs

- **Plan path**: Path to the planify-generated plan file (e.g., `docs/plans/YYYY-MM-DD-<topic>.md`). User may provide or infer from context.
- If the workspace has multiple plans or the path is ambiguous, ask the user which plan to use.

## Output

- A set of Kanban cards, one per task, each containing:
  - Task title and number
  - Link to the source plan
  - Summary
  - Files table
  - Red light scenarios (Given/When/Then)
  - Green light steps
  - Refactor items
  - Verification checklist
  - Dependency link to the previous task's card (except for Task 1)
- A summary report confirming the card count and dependency chain.
