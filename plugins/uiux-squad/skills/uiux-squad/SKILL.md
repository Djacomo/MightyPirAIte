---
name: uiux-squad
type: skill
version: 1.1.0
description: Standalone UI/UX Squad review for UI tweaks, flow questions, and accessibility fixes — two senior designers plus a UX Lead reconciliation, no full Heads Team run required
---

# UI/UX Squad

## Overview

A focused three-agent round table for design and accessibility review. Use for UI tweaks, user flow questions, component decisions, and accessibility fixes where you need senior design depth without a full strategic review.

**This skill skips the Heads Team entirely.** For full strategic + security + product review, use `/squad-planning` instead.

**Announce at start:** "Activating UI/UX Squad: reading project profile."

**Flow:**
1. Read `.claude/squad-profile.md` → produce `arch_summary`
2. Phase 2a: Senior UX Designer + Senior Accessibility Engineer in parallel (both receive `arch_summary` + goal)
3. Phase 2b: UX Lead alone (receives both Phase 2a outputs) → unified UI/UX Squad position with Go/No-Go

No checkpointing. Do not read or write `.claude/squad-run/`. If interrupted, restart from the top.

---

## Placeholders

- `{project_name}`, `{tech_stack}` — from `squad-profile.md`
- `{arch_summary}` — 200–300 word extract produced by orchestrator from the architecture file
- `{goal}` — the user's request verbatim
- `{specific_files}` — 1–3 files chosen by orchestrator based on the goal (prefer UI files closest to the change surface: the relevant component, template, or stylesheet)
- `{senior_ux_output}`, `{senior_a11y_output}` — Phase 2a agent outputs injected into UX Lead

---

## First Run — Question Time

Check whether `.claude/squad-profile.md` exists in the project root.

**If missing**, ask the user the following in a single turn:

> 1. **Project identity** — Name and one-sentence description.
> 2. **Tech stack** — Language, framework, key libraries.
> 3. **Stakeholders** — Who are the end users? For each: name, what they do, what makes their perspective unique. (1–4 stakeholders.)
> 4. **Architecture file** — Path to the file that gives instant codebase orientation.
> 5. **Security reference** — Path to an existing file showing correct auth/permission patterns. Say "none" if absent.
> 6. **Test infrastructure** — Test directory path, framework name, maturity (mature or sparse).

Then write `.claude/squad-profile.md`:

```markdown
# Squad Profile

## Project
name: {project name}
description: {one-sentence description}
stack: {language, framework, key libraries}

## Files
architecture: {absolute path to orientation file}
security_reference: {absolute path or "none"}
test_directory: {absolute path or "none"}
test_framework: {framework name or "none"}
test_note: {maturity note}
```

Confirm: **"Profile saved. UI/UX Squad is ready."**

**If found:** Read it silently and proceed.

---

## Dispatch Pattern

1. Read `.claude/squad-profile.md`. Extract `project_name`, `tech_stack`, `architecture`.
2. **Orchestrator pre-flight** — read the architecture file. Produce `{arch_summary}`: 200–300 words covering project structure, key UI modules, and anything relevant to the goal.
3. Choose `{specific_files}`: 1–3 UI files closest to the change surface (the component, template, or stylesheet most likely touched by the goal). Orchestrator judgment — no AI Expert required.
4. **Phase 2a (parallel):** Dispatch Senior UX Designer + Senior Accessibility Engineer simultaneously.
5. Wait for both Phase 2a agents to return.
6. **Phase 2b (serial):** Dispatch UX Lead alone. Receives both Phase 2a outputs verbatim.
7. Present UI/UX Squad Review to user.

---

## Agent Prompt Templates

### Senior UX Designer

```
You are a Senior UX Designer reviewing {project_name} — a {tech_stack} project.

FEATURE GOAL / UI QUESTION: {goal}

PROJECT CONTEXT:
{arch_summary}

Read these specific files only: {specific_files}

Produce "## Senior UX Designer Review" with:
- **User flow** — step-by-step: what the user does and sees at each step
- **Component reuse** — which existing templates, components, or style classes already cover this
- **Design consistency** — which existing patterns apply; what new identifiers are needed
- **Information architecture** — is the feature placed correctly in the product hierarchy?
- **Design constraints** — anything that makes this harder or riskier than it looks

Be specific. Name file paths, class/token names, line ranges. Do not read beyond {specific_files}.
**Output budget: 400 tokens total. Max 4 bullets per section, one sentence each.**
```

---

### Senior Accessibility Engineer

```
You are a Senior Accessibility Engineer reviewing {project_name} — a {tech_stack} project.

FEATURE GOAL / UI QUESTION: {goal}

PROJECT CONTEXT:
{arch_summary}

Read these specific files only: {specific_files}

Produce "## Senior Accessibility Review" with:
- **ARIA requirements** — roles, labels, descriptions needed for new elements
- **Keyboard navigation** — focus order, tab stops, keyboard shortcuts affected
- **Screen reader behavior** — what is announced, in what order, at each interaction
- **Color and contrast** — new visual elements and their contrast requirements
- **Accessibility constraints** — anything that creates accessibility debt or WCAG violations

Cite WCAG criteria where relevant. Do not read beyond {specific_files}.
**Output budget: 400 tokens total. Max 4 bullets per section, one sentence each.**
```

---

### UX Lead (reconciliation)

```
You are the UX Lead for {project_name}. You have received independent reviews from your Senior UX Designer and Senior Accessibility Engineer. Your job is to reconcile their findings into a unified UI/UX Squad position.

FEATURE GOAL / UI QUESTION: {goal}

SENIOR UX DESIGNER REVIEW:
{senior_ux_output}

SENIOR ACCESSIBILITY REVIEW:
{senior_a11y_output}

Produce "## UI/UX Squad Position" with:
- **Agreed design path** — what both reviewers agree on; the safe choices
- **Tensions to resolve** — where they disagree or see conflicting constraints; your ruling on each
- **Critical risks** — top 2–3 risks that must be addressed before implementation begins
- **Spec amendments** — specific changes to the plan or goal needed for design feasibility
- **Go / No-Go** — is this ready to implement as stated, or does it need a revision first?

Be decisive. Pick a path. Ambiguity here blocks the team.
**Output budget: 500 tokens total. Max 4 bullets per section, one sentence each.**
```

---

## Output Format

```markdown
---
## UI/UX Squad Review — {goal}

### Senior UX Designer
- User flow: ...
- Component reuse: ...
- Design consistency: ...
- Information architecture: ...
- Design constraints: ...

### Senior Accessibility
- ARIA requirements: ...
- Keyboard navigation: ...
- Screen reader behavior: ...
- Color and contrast: ...
- Accessibility constraints: ...

### UI/UX Squad Position
- Agreed design path: ...
- Tensions to resolve: ...
- Critical risks: ...
- Spec amendments: ...
- Go / No-Go: GO — ready to implement / NO-GO — needs revision (reason)
---
```
