---
name: cardify
description: Transforms a planify-generated plan into Kanban cards—one card per task, each with Red/Green/Refactor flow, linked in dependency order. Use when the user has a plan and wants to create trackable Kanban cards for each task.
compatibility: 'Requires: Kanban CLI (`kanban`), filesystem access, ability to read plan files from docs/plans/.'
---

# Cardify

Transforms a planify-generated implementation plan into a set of Kanban cards—one card per task—ready for tracking and execution. Each card includes the Red light, Green light, Refactor workflow from buildify, and cards are linked in dependency order to match the plan's task sequence.

## CRITICAL: Use the Kanban CLI

**You MUST use the `kanban` CLI to create all cards. Do NOT create markdown files manually.**

- The `kanban` CLI should be available in PATH (use `kanban` command).
- Use `kanban task create --prompt "<content>"` to create each card.
- Use `kanban task link --from <task-id> --to <blocking-task-id>` to create dependencies.
- **NEVER** create `.md` files as a substitute for Kanban cards.
- **NEVER** invent your own card format—follow the template strictly.

## Principles

- **One card per task**: Each task in the plan becomes its own Kanban card; do not merge or split tasks.
- **Preserve plan order**: Cards are created in the same order as tasks appear in the plan, forming a dependency chain.
- **Include full R/G/R flow**: Every card contains the Red light, Green light, Refactor steps from the plan, formatted for execution.
- **Link cards sequentially**: Each newly created card links to the previously created card, establishing a clear dependency chain.
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

### 4. Create Kanban cards (in plan order)

**IMPORTANT**: Use the `kanban` CLI to create each card. Run commands from your workspace.

For **each task** in the plan, in order:

1. **Create a new Kanban card** using the task template:
   - Execute: `kanban task create --prompt "<card content>"`
   - Fill in the card content using `skills/cardify/assets/task-template.md` exactly. Replace the template placeholders with the corresponding values from the task in the plan.

2. **Link to the previous card** (dependency chain):
   - For Task 1: No dependency needed (first task).
   - For Task 2 and beyond: Execute `kanban task link --from <current-task-id> --to <previous-task-id>`
   - The `--from` task waits on `--to` task (dependency).

3. **Record the card reference**:
   - Store the card ID returned by `kanban task create` for use in linking the next card.

4. **Confirm card creation** before proceeding to the next task.

### 5. Confirm dependency chain

After all cards are created:

- List all cards in order with their dependencies:
  - Task 1: (no dependency)
  - Task 2: depends on Task 1
  - Task 3: depends on Task 2
  - ... and so on
- Verify the chain matches the plan's task order.
- Report the total number of cards created and the dependency chain structure.

### 6. Summary

- Report completion: number of cards created, plan source, and dependency chain.
- Remind the user that each card can be executed using the buildify skill.

## Rules

- **MANDATORY: Use the `kanban` CLI** for all card operations. Do NOT create markdown files manually.
- **MANDATORY: Use the template** from `skills/cardify/assets/task-template.md` for all card content. Do NOT invent your own format.
- Create cards in the exact order tasks appear in the plan; do not reorder.
- Do not merge multiple tasks into one card; one task = one card.
- Do not split a single task into multiple cards.
- Every card must include the Red light, Green light, Refactor sections from the plan.
- Every card (except the first) must link to the previous card as a dependency using `kanban task link`.
- If the plan has no tasks, stop and report that there is nothing to cardify.
- If a task is missing required sections (e.g., no Red light), note it but create the card with available content.

## Stop immediately when

- The provided file is not a valid planify-generated plan.
- The plan cannot be parsed (missing structure, corrupted format).
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
