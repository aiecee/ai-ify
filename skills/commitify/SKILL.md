---
name: commitify
description: Drafts Conventional Commit messages from staged or branch changes by first classifying the change as feat, fix, or chore, then producing a concise subject and optional body and committing the selected changes. Use when the user asks for help writing a commit message, naming a commit, summarizing git diff changes into a Conventional Commit, or creating a git commit.
compatibility: 'Requires: git, filesystem access, and ability to inspect staged or branch changes.'
---

# Commitify

Turns staged or pending changes into a Conventional Commit message and uses that message to create the git commit. Start by asking whether the change should be `feat`, `fix`, or `chore`. If the diff contains multiple unrelated concerns, recommend splitting them into separate commits before drafting anything.

## Inputs

- **Change source**: staged diff, working tree diff, or branch diff.
- **Commit shape**: one commit or a small series of commits.
- **Commit class**: `feat`, `fix`, or `chore`.
- **Commit target**: already staged changes only, or a specific set of files that still need staging.
- **Optional context**: preferred scope, ticket reference, or whether the change is breaking.

## Workflow

### 1. Load the change context

- Read `assets/conventional-commits-spec.md` before drafting any commit message. Treat it as the canonical formatting reference for this skill.
- Inspect the relevant diff before drafting.
- Prefer staged changes when the user is preparing the next commit.
- If it is unclear whether to use staged changes, unstaged changes, or the full branch diff, ask the user.

### 2. Ask for the commit class

- If the user has not already specified a type, ask whether this change is a `feat`, `fix`, or `chore`.
- Use `AskQuestion` when available.
- Use these definitions exactly:
  - `feat`: new functionality or an improvement to existing functionality.
  - `fix`: a bug fix or regression fix.
  - `chore`: maintenance work such as dependency bumps, tooling upkeep, README changes, or documentation-only upkeep.

### 3. Check whether the changes belong in one commit

- If the diff mixes unrelated work, recommend splitting it into separate commits before drafting messages.
- If the changes form one coherent unit, continue with a single message.

### 4. Choose an optional scope

- Add a scope only when it clarifies the affected area, such as a package name, app area, or subsystem.
- Keep scopes short and codebase-grounded.
- Omit the scope when it would be vague, redundant, or noisy.

### 5. Draft the subject

- Use the format `<type>[optional scope]: <description>`.
- Write the description in the imperative mood.
- Keep it concise and specific to the actual change.
- Prefer the user-selected type over inferred alternatives.

### 6. Draft the optional body

- Add a body when the subject alone does not explain why the change matters.
- Focus the body on context, intent, or impact rather than repeating the subject.
- Keep the body short unless the change is complex.

### 7. Handle breaking changes when needed

- If the change introduces a breaking API or behavior change, mark it with `!` after the type or scope.
- Represent breaking changes in the header with `!`.
- Put any extra explanation in the body, not in a `BREAKING CHANGE:` footer.

### 8. Self-check before committing

- Confirm the message matches the selected type.
- Confirm the subject only describes behavior present in the diff.
- Confirm the wording is concise, imperative, and free of repo-specific jargon unless that jargon appears in the codebase.
- If any part is ambiguous, say so instead of guessing.

### 9. Create the commit

- If the intended files are not yet staged, stage only the files that belong in this commit.
- Do not stage unrelated changes just to make the commit succeed.
- Commit the staged changes using the drafted Conventional Commit message.
- If the commit fails because hooks modify files or report issues, inspect the result, restage only the relevant files, and retry with a new commit attempt that preserves the same message intent.
- After the commit succeeds, verify that the commit only captured the intended changes.

## Rules

- Ask the user to choose among `feat`, `fix`, or `chore` before drafting unless they have already chosen.
- Treat `feat` as both new features and meaningful improvements to existing features.
- Treat `fix` as bug-fix or regression-fix work.
- Treat `chore` as project maintenance, including dependency updates, tooling upkeep, README changes, and documentation-only upkeep.
- Do not silently switch to other Conventional Commit types such as `docs`, `refactor`, or `test` unless the user explicitly asks to expand the allowed type set.
- Do not invent implementation details, scope names, or motivation that are not grounded in the diff or user context.
- Prefer one coherent commit message per coherent change.
- If the diff contains multiple unrelated concerns, recommend separate commits instead of forcing one message.
- Always represent breaking changes with `!` in the header, not with a `BREAKING CHANGE:` footer.
- Do not commit unrelated staged or unstaged changes; keep the commit scoped to the selected change set.
