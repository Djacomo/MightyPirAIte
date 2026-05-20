---
name: dev-squad
type: skill
version: 1.1.0
description: Standalone Dev Squad review for bugs and small features — two senior engineers plus a Dev Lead reconciliation, no full Heads Team run required
---

# Dev Squad

## Overview

A focused three-agent round table for implementation-level review. Use for bugs, small features, and technical questions where you need senior dev depth without a full strategic review.

**This skill skips the Heads Team entirely.** For full strategic + security + product review, use `/squad-planning` instead.

**Announce at start:** "Activating Dev Squad: reading project profile."

**Flow:**
1. Read `.claude/squad-profile.md` → produce `arch_summary`
2. Phase 2a: Senior Backend + Senior Frontend in parallel (both receive `arch_summary` + goal)
3. Phase 2b: Dev Lead alone (receives both Phase 2a outputs) → unified Dev Squad position with Go/No-Go

No checkpointing. Do not read or write `.claude/squad-run/`. If interrupted, restart from the top.

---

## Placeholders

- `{project_name}`, `{tech_stack}` — from `squad-profile.md`
- `{arch_summary}` — 200–300 word extract produced by orchestrator from the architecture file
- `{goal}` — the user's request verbatim
- `{specific_files}` — 1–3 files chosen by orchestrator based on the goal (prefer files closest to the change surface: the most relevant handler, component, or model)
- `{senior_backend_output}`, `{senior_frontend_output}` — Phase 2a agent outputs injected into Dev Lead

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

Confirm: **"Profile saved. Dev Squad is ready."**

**If found:** Read it silently and proceed.

---

## Dispatch Pattern

1. Read `.claude/squad-profile.md`. Extract `project_name`, `tech_stack`, `architecture`.
2. **Orchestrator pre-flight** — read the architecture file. Produce `{arch_summary}`: 200–300 words covering project structure, key modules, and anything relevant to the goal.
3. Choose `{specific_files}`: 1–3 files closest to the change surface (the handler, component, or model most likely touched by the goal). Orchestrator judgment — no AI Expert required.
4. **Phase 2a (parallel):** Dispatch Senior Backend Engineer + Senior Frontend Engineer simultaneously.
5. Wait for both Phase 2a agents to return.
6. **Phase 2b (serial):** Dispatch Dev Lead alone. Receives both Phase 2a outputs verbatim.
7. Present Dev Squad Review to user.

---

## Agent Prompt Templates

### Senior Backend Engineer

```
You are a Senior Backend Engineer reviewing implementation feasibility for {project_name} — a {tech_stack} project.

FEATURE GOAL / BUG: {goal}

PROJECT CONTEXT:
{arch_summary}

Read these specific files only: {specific_files}

Produce "## Senior Backend Review" with:
- **API / service layer** — what endpoints, functions, or services need to be created or modified; exact paths
- **Data layer** — queries, models, migrations, indexes affected
- **Performance concerns** — N+1 queries, missing indexes, blocking operations, cache opportunities
- **Integration risks** — external services, async jobs, event flows that could break
- **Implementation constraints** — anything that makes this harder than it looks

Be specific. Cite file:line. Do not read beyond {specific_files}.
**Output budget: 400 tokens total. Max 4 bullets per section, one sentence each.**
```

---

### Senior Frontend Engineer

```
You are a Senior Frontend Engineer reviewing implementation feasibility for {project_name} — a {tech_stack} project.

FEATURE GOAL / BUG: {goal}

PROJECT CONTEXT:
{arch_summary}

Read these specific files only: {specific_files}

Produce "## Senior Frontend Review" with:
- **Component structure** — which components need to be created or modified; exact paths
- **State management** — what state changes, where it lives, how it flows
- **API integration** — how the frontend calls the backend; error states, loading states
- **Bundle / performance** — any new dependencies, code-splitting needs, render concerns
- **Implementation constraints** — anything that makes this harder than it looks

Be specific. Cite file:line. Do not read beyond {specific_files}.
**Output budget: 400 tokens total. Max 4 bullets per section, one sentence each.**
```

---

### Dev Lead (reconciliation)

```
You are the Dev Lead for {project_name}. You have received independent reviews from your Senior Backend and Senior Frontend engineers. Your job is to reconcile their findings into a unified Dev Squad position.

FEATURE GOAL / BUG: {goal}

SENIOR BACKEND REVIEW:
{senior_backend_output}

SENIOR FRONTEND REVIEW:
{senior_frontend_output}

Produce "## Dev Squad Position" with:
- **Agreed implementation path** — what both engineers agree on; the safe choices
- **Tensions to resolve** — where they disagree or see conflicting constraints; your ruling on each
- **Critical risks** — top 2–3 risks that must be addressed before implementation begins
- **Spec amendments** — specific changes to the plan or goal needed for implementation feasibility
- **Go / No-Go** — is this ready to implement as stated, or does it need a revision first?

Be decisive. Pick a path. Ambiguity here blocks the team.
**Output budget: 500 tokens total. Max 4 bullets per section, one sentence each.**
```

---

## Output Format

```markdown
---
## Dev Squad Review — {goal}

### Senior Backend
- API / service layer: ...
- Data layer: ...
- Performance concerns: ...
- Integration risks: ...
- Implementation constraints: ...

### Senior Frontend
- Component structure: ...
- State management: ...
- API integration: ...
- Bundle / performance: ...
- Implementation constraints: ...

### Dev Squad Position
- Agreed implementation path: ...
- Tensions to resolve: ...
- Critical risks: ...
- Spec amendments: ...
- Go / No-Go: GO — ready to implement / NO-GO — needs revision (reason)
---
```
