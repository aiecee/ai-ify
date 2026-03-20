# ai-ify

`ai-ify` is a small library of reusable agent skills that help teams go from idea to design, plan, build, and verification with a more consistent workflow.

## What This Repo Contains

This repo is organized around a small workflow-oriented set of skills:

- [`skills/specify`](skills/specify): turns an idea into a design doc through a structured discovery and approval flow.
- [`skills/planify`](skills/planify): turns a design doc or requirements into an implementation plan organized into behaviour-focused Red / Green / Refactor tasks.
- [`skills/buildify`](skills/buildify): executes an implementation plan task by task with scope control, verification, and feedback loops.
- [`skills/verifyify`](skills/verifyify): checks completed work against the design doc and plan, runs verification, and flags gaps before human review.

Together, these skills support an end-to-end workflow from idea refinement through implementation and final verification.

## Typical Workflow

These skills usually work best in this order:

1. `specify` to turn a rough idea into a design document.
2. `planify` to turn that design into an implementation plan with concrete tasks.
3. `buildify` to execute the plan task by task.
4. `verifyify` to confirm the implementation matches the plan and design.

A typical flow looks like this:

`idea -> design doc -> implementation plan -> build tasks -> verification`

## Core Skill Map

### `specify`

Use `specify` when you have an idea and want help shaping it into an approved design. It explores project context, asks clarifying questions one at a time, proposes approaches, and writes the resulting design to `docs/plans/`.

### `planify`

Use `planify` when you already have a design doc, spec, or clear requirements and want an implementation plan. It splits work into vertical tasks by behaviour and structures each task around `Red light`, `Green light`, and `Refactor`.

### `buildify`

Use `buildify` when you want an agent to execute a plan. It works task by task, keeps execution inside the task scope, uses a Red / Green / Refactor loop, verifies progress, and incorporates feedback before moving on.

### `verifyify`

Use `verifyify` when implementation is complete and you want a pre-review verification pass. It compares the current changes against the design and plan, runs tests and checks, and highlights scope drift, missing work, or polish issues.

## Installation

These skills can be used anywhere that supports `agentskills.io`. If you're using Cursor, one straightforward option is to link them into `~/.cursor/skills/`.

From the repository root, you can link all skills into Cursor with:

```bash
mkdir -p ~/.cursor/skills
for skill in skills/*; do
  ln -sfn "$PWD/$skill" "$HOME/.cursor/skills/$(basename "$skill")"
done
```

If you only want a subset of the skills, link the individual directories you need instead. For other agent tools, use the setup approach that matches that tool's `agentskills.io` integration model.

## Usage Examples

- Use `specify` when the request is still fuzzy: "Design a wishlist feature for the app."
- Use `planify` after the design is approved: "Create an implementation plan for the wishlist design."
- Use `buildify` once the plan exists: "Implement `docs/plans/YYYY-MM-DD-wishlist.md`."
- Use `verifyify` before human review: "Verify the wishlist implementation against the design doc and plan."
- Use the same skill flow whether you're working in Cursor, Claude, Cline, or another agent environment that supports `agentskills.io`.

## What Is Not In This Repo

This repository only contains custom skills that are owned and maintained here.

- Built-in Cursor skills in `~/.cursor/skills-cursor` are not mirrored here.
- Plugin-managed or tool-managed skills are also excluded because they are maintained outside this repository.

That separation helps keep the repo focused on the workflow and conventions you want to evolve over time, without mixing in platform-managed defaults.
