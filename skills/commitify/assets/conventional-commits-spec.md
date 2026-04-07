# Conventional Commits Reference

This asset is a concise local reference for Conventional Commits 1.0.0. It is intentionally shorter than the full specification and is meant to support `commitify` when drafting messages.

Source: [Conventional Commits 1.0.0](https://www.conventionalcommits.org/en/v1.0.0/#specification)

## Core Structure

Use this shape:

```text
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

- `type` is required.
- `scope` is optional and goes in parentheses.
- `description` is required and should be a short summary.
- `body` and `footer(s)` are optional and start after a blank line.

## Default Types For This Skill

`commitify` supports these default types:

- `feat`: new functionality or an improvement to existing functionality.
- `fix`: a bug fix or regression fix.
- `chore`: project maintenance such as dependency bumps, tooling upkeep, README changes, or documentation-only upkeep.

The broader Conventional Commits ecosystem allows additional types, but this skill defaults to these three unless the user explicitly asks otherwise.

## Scope

- A scope is optional.
- Use it only when it adds clear context, such as a subsystem, package, or feature area.
- Keep it short and noun-like, for example `auth`, `api`, or `build`.

## Description

- The description follows the colon and space immediately.
- Keep it concise and specific.
- Use the imperative mood.

## Body

- Add a body when the subject alone is not enough.
- Use the body to explain why the change matters, important context, or notable implementation choices.
- Do not use the body to restate the subject line word-for-word.

## Footers

- Footers are optional and appear after a blank line following the body.
- Footers follow a git trailer-style shape such as `Refs: #123` or `Reviewed-by: Name`.
- Multiple footers are allowed.

## Breaking Changes

```text
feat(api)!: remove v1 token endpoint
```

- `!` appears immediately before the colon.
- Always represent breaking changes with `!` in the header; do not use a `BREAKING CHANGE:` footer.
- If more explanation is needed, include it in the body instead.

## Splitting Mixed Changes

If one diff contains multiple unrelated concerns, prefer multiple commits. Conventional Commits work best when one commit communicates one coherent intent.

## Practical Checks

Before finalizing a message, confirm:

- the type matches the user-selected intent
- the scope is helpful rather than noisy
- the description reflects the diff accurately
- the body adds context instead of repetition
- any breaking change is marked with `!` in the header
