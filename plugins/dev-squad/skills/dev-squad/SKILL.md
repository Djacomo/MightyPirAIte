---
name: dev-squad
description: Standalone Dev Squad review for bugs and small features — two senior engineers plus a Dev Lead reconciliation, no full Heads Team run required
---

# Dev Squad

## Overview

A focused three-agent round table for implementation-level review. Use for bugs, small features, and technical questions where you need senior dev depth without a full strategic review.

**Announce at start:** "Activating Dev Squad: reading project profile."

**Flow:**
1. Read `squad-profile.md` → produce `arch_summary`
2. Phase 2a: Senior Backend + Senior Frontend in parallel (both receive `arch_summary` + goal)
3. Phase 2b: Dev Lead alone (receives both Phase 2a outputs) → unified Dev Squad position

No checkpointing (3 agents, fast enough to restart).

---

## First Run — Question Time

Check whether `.claude/squad-profile.md` exists. If missing, run Question Time (same questions as `/squad-planning`) and write the profile before proceeding.

---

## Dispatch Pattern

1. Read `.claude/squad-profile.md`.
2. **Orchestrator pre-flight** — read the architecture file from the profile. Produce `{arch_summary}`: 200–300 word extract covering project structure, key modules, and anything relevant to the goal.
3. Evaluate goal: are both Backend and Frontend surfaces involved? If only one, note it but still dispatch both (the uninvolved engineer will report minimal findings).
4. **Phase 2a (parallel):** Dispatch Senior Backend Engineer + Senior Frontend Engineer simultaneously. Both receive `{arch_summary}` + goal + `{specific_files}` (orchestrator judgment if no AI Expert ran).
5. Wait for both Phase 2a agents to return.
6. **Phase 2b (serial):** Dispatch Dev Lead alone. Receives both Phase 2a outputs verbatim.
7. Present Dev Squad Position to user.

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
- **Agreed implementation path** — what both engineers agree on
- **Tensions to resolve** — where they disagree; your ruling on each
- **Critical risks** — top 2–3 risks before implementation begins
- **Recommended next step** — one sentence: what to do first

Be decisive. Pick a path.
**Output budget: 350 tokens total. Max 4 bullets per section, one sentence each.**
```

---

## Output Format

```markdown
---
## Dev Squad Review — {goal}

### Senior Backend
{bullets}

### Senior Frontend
{bullets}

### Dev Squad Position
{bullets from Dev Lead}
---
```
