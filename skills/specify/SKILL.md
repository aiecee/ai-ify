---
name: specify
description: Turns ideas into design docs via a fixed workflow—explore context, clarify one question per message, propose 2-3 approaches, present design in sections for approval, write to docs/plans/. Use when the user wants to specify an idea or create a design doc.
---

# Specify

Turns an idea into a design doc through a fixed 5-step workflow. Do not skip steps. Only one question per message; if a topic needs more exploration, break it into multiple questions.

## Workflow (strict order)

### 1. Explore project context (understand the idea)

- **First:** Check out the current project state — relevant files, docs (e.g. README, CLAUDE.md, planning/ or docs/), and recent history (e.g. `git log -5 --oneline`) so the design is grounded in the repo.
- Summarize what was found in 1–2 short paragraphs; do not skip this step.

### 2. Ask questions to refine the idea

- **Focus on understanding:** purpose, constraints, success criteria.
- **Only one question per message.** Wait for the user's answer before asking the next. If a topic needs more exploration, break it into multiple questions (one per message).
- **Prefer multiple-choice questions** when possible; open-ended is fine when choices don't fit.
- Continue until purpose, constraints, and success criteria are clear (or the user says to proceed).

### 3. Propose 2–3 approaches

- Present 2–3 concrete approaches (names, 1–2 sentence summary each).
- For each: brief trade-offs (e.g. complexity, risk, time, maintainability).
- End with **your recommendation** and one sentence why.

### 4. Present the design

- **When:** Once you believe you understand what you're building, present the design.
- **Sections to cover:** architecture, components, data flow, error handling, testing. Add or drop sections only if the idea clearly demands it (e.g. rollout, open questions).
- **Scale each section to its complexity:** a few sentences if straightforward; up to 200–300 words if nuanced. Do not pad simple topics or truncate complex ones.
- **One section at a time.** After each section, ask whether it looks right so far (e.g. "Does this look right so far, or should we change anything?"). Wait for a response before continuing. If something doesn't make sense to the user, go back and clarify; do not proceed until they're satisfied.
- Do not write the full doc to disk until all sections are approved.

### 5. Write design doc

- **Path:** `docs/plans/YYYY-MM-DD-<topic>-design.md` (topic = short slug, e.g. `wishlist`, `checkout-refactor`). Use the project/repo root (current workspace). Create `docs/plans/` if it does not exist. If the workspace has no single obvious repo root (e.g. multi-root), use the repo root that contains the code this idea applies to, or ask the user where to save the doc.
- **Content:** The approved design, in markdown, following the design doc template. When writing the doc, read **assets/design-doc-template.md** (relative to this skill directory) and use that structure; scale each section to complexity (a few sentences up to 200–300 words), omit optional sections if not needed.
