# Squad Planning v3 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Upgrade squad-planning to a two-tier Tavola Rotonda system with Heads Team + specialist squads, checkpoint/resume, and two new standalone skills (`/dev-squad`, `/uiux-squad`).

**Architecture:** Three SKILL.md files live in `plugins/<name>/skills/<name>/SKILL.md` and are deployed to `~/.claude/skills/<name>/SKILL.md` via `deploy-skills.sh`. The full cascade (`/squad-planning`) runs Heads Team first (Phase 0 AI Expert → Phase 1a Arch anchor → Phase 1b parallel) then Specialist Squads in parallel (each a mini round table). Checkpoints are written to `.claude/squad-run/` after every phase. Standalone squads (`/dev-squad`, `/uiux-squad`) skip the Heads Team entirely.

**Tech Stack:** Markdown skill files, Bash deploy script, Claude Code plugin system.

---

## File Map

| File | Action |
|---|---|
| `plugins/squad-planning/skills/squad-planning/SKILL.md` | Rewrite — v3 full cascade |
| `plugins/squad-planning/.claude-plugin/plugin.json` | Update description |
| `plugins/dev-squad/skills/dev-squad/SKILL.md` | Create |
| `plugins/dev-squad/.claude-plugin/plugin.json` | Create |
| `plugins/uiux-squad/skills/uiux-squad/SKILL.md` | Create |
| `plugins/uiux-squad/.claude-plugin/plugin.json` | Create |

`deploy-skills.sh` automatically picks up any `plugins/*/skills/*/SKILL.md` — no changes needed to it.

---

## Task 1: Rewrite squad-planning SKILL.md (v3)

**Files:**
- Modify: `plugins/squad-planning/skills/squad-planning/SKILL.md`

- [ ] **Step 1: Overwrite the file with the v3 content**

Replace the entire file with:

```markdown
---
name: squad-planning
description: Use when starting any planning, spec, or handoff writing activity — invoke before writing any spec, plan, or handoff document to get parallel squad review; first run triggers project setup
---

# Squad Planning

## Overview

Squad Planning runs a **two-tier Tavola Rotonda** before any spec or plan is written.

- **Tier 1 — Heads Team**: Strategic, cross-cutting review. Produces the "Heads Brief".
- **Tier 2 — Specialist Squads**: Dev Squad and UI/UX Squad receive the Brief and go deep in their domain via a mini round table.

**This skill is project-agnostic.** All project-specific context lives in `.claude/squad-profile.md`.

**Announce at start:** "Activating Heads Team: reading project profile — evaluating roster."

**Checkpoint directory:** `.claude/squad-run/` — written after every phase. Delete it to start a fresh run.

---

## First Run — Question Time

Check whether `.claude/squad-profile.md` exists in the project root.

**If missing:** Ask the user the following in a single turn:

> 1. **Project identity** — Name and one-sentence description.
> 2. **Tech stack** — Language, framework, key libraries.
> 3. **Stakeholders** — Who are the end users? For each: name, what they do, what makes their perspective unique. (1–4 stakeholders.)
> 4. **Architecture file** — Path to the file that gives instant codebase orientation.
> 5. **Security reference** — Path to an existing file showing correct auth/permission patterns. Say "none" if absent.
> 6. **Test infrastructure** — Test directory path, framework name, maturity (mature or sparse).

Write `.claude/squad-profile.md` using the template below and confirm: **"Profile saved. Squad is ready."**

**If found:** Read it silently and proceed to Checkpoint Check.

### Profile File Template

```markdown
# Squad Profile

## Project
name: {project name}
description: {one-sentence description}
stack: {language, framework, key libraries}

## Files
architecture: {absolute path to orientation file}
security_reference: {absolute path to security pattern reference, or "none"}
test_directory: {absolute path to test directory}
test_framework: {framework name}
test_note: {maturity note}

## Stakeholders

### {Stakeholder 1 Name}
description: {who they are and what they do}
reads: {absolute paths to files most relevant to their perspective}
evict_when: {condition under which this stakeholder is irrelevant to the goal}
voice: {tone — e.g. "first person, non-technical, honest about confusion"}
```

---

## Checkpoint Check

On every run, before dispatching anything, check `.claude/squad-run/` for existing checkpoint files. Restore completed phases from disk; dispatch only missing ones.

**Checkpoint files and what they represent:**

| File | Phase |
|---|---|
| `dispatch-plan.md` | Phase 0 — AI Expert output |
| `arch-anchor.md` | Phase 1a — Arch Lead output |
| `heads-brief.md` | Phase 1b — Heads Team compressed brief |
| `dev-squad.md` | Phase 2 — Dev Squad unified position |
| `uiux-squad.md` | Phase 2 — UI/UX Squad unified position |
| `synthesis.md` | Final synthesis |

**Announce restored vs. dispatched:**

```
Resuming squad run.
✓ Phase 0 restored  (dispatch-plan.md)
✓ Phase 1a restored (arch-anchor.md)
↻ Phase 1b dispatching — no checkpoint found
```

For a fresh run (no checkpoints), announce:

```
Fresh squad run.
Phase 0: AI Expert dispatched.
Heads Team roster: PM ✓ | Arch Lead ✓ | DevSecOps ✓ | Good-Hacker ✓ | QA ✓ | {Stakeholder 1} ✗ (reason)
Phase 2: Dev Squad ✓ | UI/UX Squad ✓
```

---

## The Heads Team (Tier 1)

| Role | Anchor? | Domain |
|---|---|---|
| **AI Expert** | Phase 0 (serial) | Dispatch planning — never evict |
| **Arch Team Lead** | Yes — Phase 1a solo | File ownership, data model, integration points, breaking changes — never evict |
| **PM** | No | Scope, MVP, delivery risk, user stories |
| **DevSecOps Leader** | No | Auth gates, input validation, data exposure, compliance |
| **Good-Hacker** | No | Offensive threat model |
| **QA/Test Engineer** | No | Test strategy, regression surface |
| **Stakeholders** | No | Loaded from squad-profile; evicted per `evict_when` |

### Heads Team Eviction Rules

| Member | Evict when |
|---|---|
| AI Expert | Never |
| Arch Team Lead | Never |
| PM | Genuine hotfix only (wrong label, broken style, single-line typo) |
| DevSecOps Leader | No new data flows, endpoints, inputs, or query parameters |
| Good-Hacker | UI/template/doc-only — no code paths, no data flow |
| QA/Test Engineer | UI/template-only with zero logic changes |
| Stakeholders | Per `evict_when` in profile |

---

## The Specialist Squads (Tier 2)

Both squads always run after the Heads Team in a full cascade. Evict a squad only if its domain is completely irrelevant (e.g., evict UI/UX Squad for a pure backend/schema change with zero rendering impact; evict Dev Squad never).

### Dev Squad

| Role | Phase |
|---|---|
| Senior Backend Engineer | Phase 2a — parallel |
| Senior Frontend Engineer | Phase 2a — parallel |
| Dev Lead | Phase 2b — reconciliation (reads both 2a outputs) |

### UI/UX Squad

| Role | Phase |
|---|---|
| Senior UX Designer | Phase 2a — parallel |
| Senior Accessibility Engineer | Phase 2a — parallel |
| UX Lead | Phase 2b — reconciliation (reads both 2a outputs) |

---

## Dispatch Pattern

### Phase 0 — AI Expert (serial)

1. Check `.claude/squad-run/dispatch-plan.md` — if exists, restore and skip to Phase 1a check.
2. Read `.claude/squad-profile.md` only.
3. Dispatch **AI Expert** as a single foreground `Agent` call (`subagent_type: "claude"`).
4. AI Expert returns Dispatch Plan: active Heads Team roster, per-agent file lists, output budgets, pre-summarize list.
5. **Write checkpoint:** `.claude/squad-run/dispatch-plan.md` ← AI Expert full output.

### Phase 1a — Arch Lead Anchor (serial)

1. Check `.claude/squad-run/arch-anchor.md` — if exists, restore and skip.
2. **Orchestrator pre-flight** — read architecture file, produce `{arch_summary}` (200–300 words).
3. If DevSecOps or Good-Hacker are active and `security_reference` is not "none", read it and produce `{security_summary}` (100–150 words).
4. Dispatch **Arch Team Lead** alone as a single foreground `Agent` call.
5. **Write checkpoint:** `.claude/squad-run/arch-anchor.md` ← Arch Lead full output.

### Phase 1b — Heads Team Parallel

1. Check `.claude/squad-run/heads-brief.md` — if exists, restore and skip.
2. Read `arch-anchor.md` content as `{arch_anchor_text}`.
3. Dispatch all active non-Arch Heads Team members in **parallel** `Agent` calls. Each receives `{arch_anchor_text}` injected as text (not re-read).
4. Wait for all to return.
5. Orchestrator compresses all Phase 1b outputs into `{heads_brief}` (~400 tokens): key constraints, risks, and decisions per domain.
6. **Write checkpoint:** `.claude/squad-run/heads-brief.md` ← compressed brief.

### Phase 2 — Specialist Squads (parallel squads, sequential within each)

Dev Squad and UI/UX Squad are dispatched to start **at the same time**. Within each squad, Phase 2b waits for Phase 2a.

**Dev Squad:**
1. Check `.claude/squad-run/dev-squad.md` — if exists, restore and skip.
2. Read `heads-brief.md` as `{heads_brief}`.
3. Phase 2a: Dispatch Senior Backend Engineer + Senior Frontend Engineer in parallel. Both receive `{heads_brief}`.
4. Phase 2b: Dispatch Dev Lead alone. Receives both Phase 2a outputs.
5. **Write checkpoint:** `.claude/squad-run/dev-squad.md` ← Dev Lead output.

**UI/UX Squad (in parallel with Dev Squad):**
1. Check `.claude/squad-run/uiux-squad.md` — if exists, restore and skip.
2. Read `heads-brief.md` as `{heads_brief}`.
3. Phase 2a: Dispatch Senior UX Designer + Senior Accessibility Engineer in parallel. Both receive `{heads_brief}`.
4. Phase 2b: Dispatch UX Lead alone. Receives both Phase 2a outputs.
5. **Write checkpoint:** `.claude/squad-run/uiux-squad.md` ← UX Lead output.

### Synthesis

1. Check `.claude/squad-run/synthesis.md` — if exists, restore and present.
2. Read all checkpoint files: `dispatch-plan.md`, `arch-anchor.md`, `heads-brief.md`, `dev-squad.md`, `uiux-squad.md`.
3. Produce Squad Review block (see Synthesis section below).
4. **Write checkpoint:** `.claude/squad-run/synthesis.md`.

---

## Agent Prompt Templates

### Placeholders

From profile: `{project_name}`, `{project_description}`, `{tech_stack}`, `{test_directory}`, `{test_framework}`, `{test_note}`.

From orchestrator pre-flight:
- `{arch_summary}` — 200–300 word architecture summary (Phase 0 pre-flight)
- `{security_summary}` — 100–150 word security patterns summary (omit if "none")
- `{arch_anchor_text}` — full Arch Lead output injected into Phase 1b agents
- `{heads_brief}` — ~400-token compressed Heads Team brief injected into Phase 2 agents
- `{specific_files}` — per-agent file list from AI Expert (1–3 files)
- `{output_budget}` — token budget from AI Expert

---

### AI Expert

```
You are the AI Efficiency Expert for {project_name} — {project_description}.

FEATURE GOAL: {goal}

Read `.claude/squad-profile.md` for full squad and project context. Do not read any other files.

Produce "## Dispatch Plan":

### Active Heads Team Roster
List each member: ✓ (keep) or ✗ (evict + one-line reason).
Evict when less than 50% chance the member surfaces something the others won't.

### Specialist Squads
Dev Squad: ✓ or ✗ (evict only for pure backend/schema changes with zero rendering impact)
UI/UX Squad: ✓ or ✗ (evict only for pure backend/schema changes with zero rendering impact)

### Pre-Summarize
- architecture file → arch_summary (always)
- security reference → security_summary (only if DevSecOps or Good-Hacker active; skip if "none")

### Per-Agent File List
For each active Heads Team member (excluding AI Expert): 1–3 specific files beyond injected summaries.

| Agent | Files to read |
|---|---|
| Arch Lead | [path], [path] |
| PM | (none — arch_summary sufficient) |
| DevSecOps | [path] |
| Good-Hacker | [path] |
| QA | [test_file] |
| {Stakeholder} | [path] |
| Senior Backend | [path] |
| Senior Frontend | [path] |
| Senior UX Designer | [path] |
| Senior Accessibility | [path] |

### Output Budgets
Pick one complexity tier:

| Tier | When | Arch | Security agents | PM | Others |
|---|---|---|---|---|---|
| Simple | 1–2 files, no new endpoints | 400t | 350t | 250t | 250t |
| Medium | 2–4 files, one new endpoint | 600t | 500t | 300t | 300t |
| Complex | schema changes, multiple endpoints | 700t | 600t | 350t | 400t |

State the tier and budget per agent.
```

---

### Arch Team Lead (Phase 1a anchor)

```
You are the Arch Team Lead for {project_name} — a {tech_stack} project.
You are the ANCHOR for this review. Your output will be shared with all other Heads Team members as their shared foundation. Be precise and complete.

FEATURE GOAL: {goal}

PROJECT CONTEXT:
{arch_summary}

Read these specific files only: {specific_files}

Produce "## Arch Lead Review" with:
- **Files to modify** — exact paths
- **Files to create** — exact paths + one-line responsibility each
- **Schema / data model changes** — what changes, what migration strategy
- **Integration points** — what calls what, in what order; hooks, events, interfaces
- **Existing patterns to follow** — cite by file:line
- **Risks & breaking changes** — anything that could regress existing behavior

Be specific. Name files, line ranges, function names. Do not read beyond {specific_files}.
**Output budget: {output_budget} tokens total. Max 4 bullets per section, one sentence each.**
```

---

### PM (Phase 1b)

```
You are the Product Manager for {project_name} — {project_description}.

FEATURE GOAL: {goal}

PROJECT CONTEXT:
{arch_summary}

ARCH LEAD REVIEW (shared foundation — do not re-read architecture file):
{arch_anchor_text}

Produce "## PM Review" with:
- **Problem statement** — one sentence: what user problem does this solve? Flag if unclear.
- **Scope check** — MVP or over-building? What could be deferred?
- **Roadmap fit** — does this align with current priorities or introduce drift?
- **Delivery risk** — dependencies, ambiguities, cross-cutting concerns
- **Missing user stories** — implied scenarios not stated in the goal
- **Definition of done** — how will we know this is complete?

Challenge the Arch Lead's scope if you disagree. Flag any tension explicitly.
**Output budget: {output_budget} tokens total. Max 4 bullets per section, one sentence each.**
```

---

### DevSecOps Leader (Phase 1b)

```
You are the DevSecOps Leader for {project_name} — a {tech_stack} project.

FEATURE GOAL: {goal}

PROJECT CONTEXT:
{arch_summary}

SECURITY PATTERNS:
{security_summary}

ARCH LEAD REVIEW (shared foundation — do not re-read architecture file):
{arch_anchor_text}

Read these specific files only: {specific_files}

Produce "## DevSecOps Review" with:
- **New attack surface** — endpoints, routes, input fields, or data flows
- **Auth & permission gates** — what checks are required
- **Input validation** — which inputs need validation/sanitization and how
- **Output encoding** — where output is rendered and what encoding is needed
- **Data exposure** — what is returned; is any of it sensitive or user-identifiable
- **Rate limiting** — is it needed; cite existing pattern from security summary
- **Compliance** — privacy, regulatory, or data retention implications

Challenge the Arch Lead's design if you see security gaps. Be specific.
**Output budget: {output_budget} tokens total. Max 4 bullets per section, one sentence each.**
```

---

### Good-Hacker (Phase 1b)

```
You are an offensive security specialist reviewing a feature design for {project_name} — a {tech_stack} project.
You are NOT running live exploits — you are building a threat model against the proposed design.

FEATURE GOAL: {goal}

PROJECT CONTEXT:
{arch_summary}

EXISTING DEFENSES:
{security_summary}

ARCH LEAD REVIEW (shared foundation — do not re-read architecture file):
{arch_anchor_text}

Read these specific files only: {specific_files}

Produce "## Good-Hacker Threat Model" with:
- **Attack surface inventory** — every new endpoint, input field, or data flow
- **Attack vectors** — for each surface: what would you try?
- **Likely successes** — which attacks would succeed and why
- **What standard defenses miss** — threats typical {tech_stack} patterns don't cover
- **Hardening requirements** — specific changes needed before shipping

Assume standard {tech_stack} security practices are in place. Find what survives them.
**Output budget: {output_budget} tokens total. Max 4 bullets per section, one sentence each.**
```

---

### QA/Test Engineer (Phase 1b)

```
You are the QA/Test Engineer for {project_name} — a {tech_stack} project.

FEATURE GOAL: {goal}

PROJECT CONTEXT:
{arch_summary}

ARCH LEAD REVIEW (shared foundation — do not re-read architecture file):
{arch_anchor_text}

Read these specific files only: {specific_files}
Test suite maturity: {test_note}

Produce "## QA/Test Engineer Review" with:
- **Unit tests required** — which classes/functions need new tests; cite existing patterns by file:line
- **Integration tests required** — which end-to-end flows need coverage
- **Regression surface** — which existing tests could break; name specific files and test methods
- **Manual test checklist** — happy path + 2 edge cases (3 scenarios max)
- **Untestable design flags** — anything that cannot be unit tested as designed

Challenge the Arch Lead's design if it makes testing hard. Flag as a spec constraint.
**Output budget: {output_budget} tokens total. Max 4 bullets per section, one sentence each.**
```

---

### Stakeholder Template (Phase 1b)

```
You are simulating {stakeholder_name} for {project_name}. {stakeholder_description}

FEATURE GOAL: {goal}

PROJECT CONTEXT:
{arch_summary}

ARCH LEAD REVIEW (shared foundation):
{arch_anchor_text}

Read these specific files only: {specific_files}

Produce "## {stakeholder_name} Review" with:
- **What I understand this does** — describe in plain language
- **How it affects my experience** — better, worse, or unclear?
- **What I'd want that isn't mentioned** — missing information or actions
- **Confusion or friction** — anything unclear, risky, or annoying
- **Pushback** — anything I'd object to or want changed

{stakeholder_voice}
**Output budget: {output_budget} tokens total. Max 3 bullets per section, one sentence each.**
```

---

### Senior Backend Engineer (Phase 2a)

```
You are a Senior Backend Engineer reviewing implementation feasibility for {project_name} — a {tech_stack} project.

FEATURE GOAL: {goal}

HEADS TEAM BRIEF (strategic review — do not re-read any file already covered here):
{heads_brief}

Read these specific files only: {specific_files}

Produce "## Senior Backend Review" with:
- **API / service layer** — what endpoints, functions, or services need to be created or modified; exact paths
- **Data layer** — queries, models, migrations, indexes affected
- **Performance concerns** — N+1 queries, missing indexes, blocking operations, cache opportunities
- **Integration risks** — external services, async jobs, event flows that could break
- **Implementation constraints** — anything that makes the Heads Team plan harder to build than it looks

Be specific. Cite file:line. Do not read beyond {specific_files}.
**Output budget: {output_budget} tokens total. Max 4 bullets per section, one sentence each.**
```

---

### Senior Frontend Engineer (Phase 2a)

```
You are a Senior Frontend Engineer reviewing implementation feasibility for {project_name} — a {tech_stack} project.

FEATURE GOAL: {goal}

HEADS TEAM BRIEF (strategic review — do not re-read any file already covered here):
{heads_brief}

Read these specific files only: {specific_files}

Produce "## Senior Frontend Review" with:
- **Component structure** — which components need to be created or modified; exact paths
- **State management** — what state changes, where it lives, how it flows
- **API integration** — how the frontend calls the backend; error states, loading states
- **Bundle / performance** — any new dependencies, code-splitting needs, render concerns
- **Implementation constraints** — anything that makes the Heads Team plan harder to build than it looks

Be specific. Cite file:line. Do not read beyond {specific_files}.
**Output budget: {output_budget} tokens total. Max 4 bullets per section, one sentence each.**
```

---

### Dev Lead (Phase 2b reconciliation)

```
You are the Dev Lead for {project_name}. You have received independent reviews from your Senior Backend and Senior Frontend engineers. Your job is to reconcile their findings into a unified Dev Squad position.

FEATURE GOAL: {goal}

SENIOR BACKEND REVIEW:
{senior_backend_output}

SENIOR FRONTEND REVIEW:
{senior_frontend_output}

Produce "## Dev Squad Position" with:
- **Agreed implementation path** — what both engineers agree on; the safe choices
- **Tensions to resolve** — where they disagree or see conflicting constraints; your ruling on each
- **Critical risks** — the top 2–3 risks that must be addressed before implementation begins
- **Spec amendments** — specific changes to the Heads Team plan needed for implementation feasibility
- **Go / No-Go** — is the feature ready to implement as specced, or does it need a design revision?

Be decisive. Pick a path. Ambiguity here blocks the team.
**Output budget: 500 tokens total. Max 4 bullets per section, one sentence each.**
```

---

### Senior UX Designer (Phase 2a)

```
You are a Senior UX Designer reviewing {project_name} — a {tech_stack} project.

FEATURE GOAL: {goal}

HEADS TEAM BRIEF (strategic review — do not re-read any file already covered here):
{heads_brief}

Read these specific files only: {specific_files}

Produce "## Senior UX Designer Review" with:
- **User flow** — step-by-step: what the user does and sees at each step
- **Component reuse** — which existing templates, components, or style classes already cover this
- **Design consistency** — which existing patterns apply; what new identifiers are needed
- **Information architecture** — is the feature placed correctly in the product hierarchy?
- **Design constraints** — anything that makes the Heads Team plan harder to design than it looks

Be specific. Name file paths, class/token names, line ranges. Do not read beyond {specific_files}.
**Output budget: {output_budget} tokens total. Max 4 bullets per section, one sentence each.**
```

---

### Senior Accessibility Engineer (Phase 2a)

```
You are a Senior Accessibility Engineer reviewing {project_name} — a {tech_stack} project.

FEATURE GOAL: {goal}

HEADS TEAM BRIEF (strategic review — do not re-read any file already covered here):
{heads_brief}

Read these specific files only: {specific_files}

Produce "## Senior Accessibility Review" with:
- **ARIA requirements** — roles, labels, descriptions needed for new elements
- **Keyboard navigation** — focus order, tab stops, keyboard shortcuts affected
- **Screen reader behavior** — what is announced, in what order, at each interaction
- **Color and contrast** — any new visual elements and their contrast requirements
- **Accessibility constraints** — anything in the Heads Team plan that creates accessibility debt

Cite WCAG criteria where relevant. Do not read beyond {specific_files}.
**Output budget: {output_budget} tokens total. Max 4 bullets per section, one sentence each.**
```

---

### UX Lead (Phase 2b reconciliation)

```
You are the UX Lead for {project_name}. You have received independent reviews from your Senior UX Designer and Senior Accessibility Engineer. Your job is to reconcile their findings into a unified UI/UX Squad position.

FEATURE GOAL: {goal}

SENIOR UX DESIGNER REVIEW:
{senior_ux_output}

SENIOR ACCESSIBILITY REVIEW:
{senior_a11y_output}

Produce "## UI/UX Squad Position" with:
- **Agreed design path** — what both reviewers agree on; the safe choices
- **Tensions to resolve** — where they disagree or see conflicting constraints; your ruling on each
- **Critical risks** — the top 2–3 risks that must be addressed before implementation begins
- **Spec amendments** — specific changes to the Heads Team plan needed for design feasibility
- **Go / No-Go** — is the feature ready to implement as designed, or does it need a revision?

Be decisive. Pick a path.
**Output budget: 500 tokens total. Max 4 bullets per section, one sentence each.**
```

---

## Synthesis

After all phases complete, produce the Squad Review block:

```markdown
---
## Squad Review — {goal}
_Heads Team: [active members] | Evicted: [members + reason] | Tier: [Simple/Medium/Complex]_
_Squads: Dev Squad [✓/✗] | UI/UX Squad [✓/✗]_

_(Omit sections for evicted members entirely.)_

### Arch Lead
{3–4 bullets from arch-anchor.md}

### PM
{3–4 bullets}

### DevSecOps
{3–4 bullets}

### Good-Hacker
{3–4 bullets}

### QA/Test Engineer
{3–4 bullets}

### {Stakeholder Name}
{2–3 bullets}

### Dev Squad
{3–4 bullets from dev-squad.md — Go/No-Go + key constraints}

### UI/UX Squad
{3–4 bullets from uiux-squad.md — Go/No-Go + key constraints}

### Conflicts & Tensions
- {member A} says {X} — {member B} says {Y}: resolution needed
- _(omit if none)_

**BLOCKER:** If any conflict requires a product or architectural decision beyond Claude's authority, stop and ask the user.

### Hard Constraints for the Spec
- {binding constraint}
- {binding constraint}
---
```

The spec is written **after** this block.

---

## Common Mistakes

| Mistake | Fix |
|---|---|
| Running without a profile | Always check for `.claude/squad-profile.md` first. |
| Not checking checkpoints on run start | Always check `.claude/squad-run/` before any dispatch. |
| Skipping Phase 0 | Phase 0 costs ~500 tokens and saves 5–10× that in Phase 1. Never skip. |
| Dispatching Phase 1b before writing arch-anchor.md | Write the checkpoint first. |
| Dispatching Phase 2 before writing heads-brief.md | Write the checkpoint first. |
| Dev Lead or UX Lead running in parallel with their team | They must run after Phase 2a completes. |
| Injecting full file content instead of summaries | arch_summary: 200–300 words. heads_brief: ~400 tokens. Never dump full files. |
| Arch Lead reading beyond specific_files | Arch Lead gets arch_summary + specific_files only. |
| Phase 1b agents re-reading the architecture file | They receive arch_anchor_text injected — no re-read. |
| Writing spec before synthesis | Squad Review is a hard gate. |
| Ignoring Dev Squad or UI/UX Squad Go/No-Go | A "No-Go" from either squad is a blocker. Ask the user before writing the spec. |
| Evicting Dev Squad | Only evict if the goal has zero implementation surface (docs, config comments). |
```

- [ ] **Step 2: Verify line count is reasonable**

```bash
wc -l plugins/squad-planning/skills/squad-planning/SKILL.md
```

Expected: between 350 and 550 lines.

- [ ] **Step 3: Commit**

```bash
git add plugins/squad-planning/skills/squad-planning/SKILL.md
git commit -m "feat: squad-planning v3 — Heads Team + Tavola Rotonda + checkpoint system"
```

---

## Task 2: Update squad-planning plugin.json

**Files:**
- Modify: `plugins/squad-planning/.claude-plugin/plugin.json`

- [ ] **Step 1: Update the description field**

In `plugins/squad-planning/.claude-plugin/plugin.json`, change the `description` value to:

```
"Dispatch a two-tier Tavola Rotonda squad before any spec or plan is written: Heads Team (AI Expert, Arch Lead anchor, PM, DevSecOps, Good-Hacker, QA) followed by Dev Squad and UI/UX Squad specialist deep-dives. Checkpoint/resume system saves progress if tokens run out. Project-agnostic — reads context from .claude/squad-profile.md."
```

Also bump `"version"` from `"1.0.0"` to `"3.0.0"`.

- [ ] **Step 2: Commit**

```bash
git add plugins/squad-planning/.claude-plugin/plugin.json
git commit -m "chore: bump squad-planning to v3.0.0, update description"
```

---

## Task 3: Create dev-squad plugin

**Files:**
- Create: `plugins/dev-squad/.claude-plugin/plugin.json`
- Create: `plugins/dev-squad/skills/dev-squad/SKILL.md`

- [ ] **Step 1: Create plugin.json**

```bash
mkdir -p plugins/dev-squad/.claude-plugin
```

Write `plugins/dev-squad/.claude-plugin/plugin.json`:

```json
{
  "name": "dev-squad",
  "description": "Standalone Dev Squad mini round table for bugs and small features — Senior Backend + Senior Frontend run in parallel, Dev Lead reconciles into a unified position. No full Heads Team run required. Reads context from .claude/squad-profile.md.",
  "version": "1.0.0",
  "author": {
    "name": "Djacomo",
    "url": "https://github.com/Djacomo"
  },
  "homepage": "https://github.com/Djacomo/MightyPirAIte/tree/master/plugins/dev-squad"
}
```

- [ ] **Step 2: Create SKILL.md**

```bash
mkdir -p plugins/dev-squad/skills/dev-squad
```

Write `plugins/dev-squad/skills/dev-squad/SKILL.md`:

```markdown
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

Check whether `.claude/squad-profile.md` exists. If missing, run Question Time (same questions as squad-planning) and write the profile before proceeding.

---

## Dispatch Pattern

1. Read `.claude/squad-profile.md`.
2. **Orchestrator pre-flight** — read the architecture file from the profile. Produce `{arch_summary}`: 200–300 word extract covering project structure, key modules, and anything relevant to the goal.
3. Evaluate goal: are both Backend and Frontend surfaces involved? If only one, note it but still dispatch both (the uninvolved engineer will report minimal findings).
4. **Phase 2a (parallel):** Dispatch Senior Backend Engineer + Senior Frontend Engineer simultaneously. Both receive `{arch_summary}` + goal + `{specific_files}` from AI Expert plan (or orchestrator judgment if no AI Expert ran).
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
```

- [ ] **Step 3: Commit**

```bash
git add plugins/dev-squad/
git commit -m "feat: add dev-squad standalone skill"
```

---

## Task 4: Create uiux-squad plugin

**Files:**
- Create: `plugins/uiux-squad/.claude-plugin/plugin.json`
- Create: `plugins/uiux-squad/skills/uiux-squad/SKILL.md`

- [ ] **Step 1: Create plugin.json**

```bash
mkdir -p plugins/uiux-squad/.claude-plugin
```

Write `plugins/uiux-squad/.claude-plugin/plugin.json`:

```json
{
  "name": "uiux-squad",
  "description": "Standalone UI/UX Squad mini round table for UI tweaks, flow questions, and accessibility fixes — Senior UX Designer + Senior Accessibility Engineer run in parallel, UX Lead reconciles into a unified position. No full Heads Team run required. Reads context from .claude/squad-profile.md.",
  "version": "1.0.0",
  "author": {
    "name": "Djacomo",
    "url": "https://github.com/Djacomo"
  },
  "homepage": "https://github.com/Djacomo/MightyPirAIte/tree/master/plugins/uiux-squad"
}
```

- [ ] **Step 2: Create SKILL.md**

```bash
mkdir -p plugins/uiux-squad/skills/uiux-squad
```

Write `plugins/uiux-squad/skills/uiux-squad/SKILL.md`:

```markdown
---
name: uiux-squad
description: Standalone UI/UX Squad review for UI tweaks, flow questions, and accessibility fixes — two senior designers plus a UX Lead reconciliation, no full Heads Team run required
---

# UI/UX Squad

## Overview

A focused three-agent round table for design and accessibility review. Use for UI tweaks, user flow questions, component decisions, and accessibility fixes where you need senior design depth without a full strategic review.

**Announce at start:** "Activating UI/UX Squad: reading project profile."

**Flow:**
1. Read `squad-profile.md` → produce `arch_summary`
2. Phase 2a: Senior UX Designer + Senior Accessibility Engineer in parallel (both receive `arch_summary` + goal)
3. Phase 2b: UX Lead alone (receives both Phase 2a outputs) → unified UI/UX Squad position

No checkpointing (3 agents, fast enough to restart).

---

## First Run — Question Time

Check whether `.claude/squad-profile.md` exists. If missing, run Question Time (same questions as squad-planning) and write the profile before proceeding.

---

## Dispatch Pattern

1. Read `.claude/squad-profile.md`.
2. **Orchestrator pre-flight** — read the architecture file from the profile. Produce `{arch_summary}`: 200–300 word extract covering project structure, key UI modules, and anything relevant to the goal.
3. **Phase 2a (parallel):** Dispatch Senior UX Designer + Senior Accessibility Engineer simultaneously. Both receive `{arch_summary}` + goal + `{specific_files}`.
4. Wait for both Phase 2a agents to return.
5. **Phase 2b (serial):** Dispatch UX Lead alone. Receives both Phase 2a outputs verbatim.
6. Present UI/UX Squad Position to user.

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
- **Agreed design path** — what both reviewers agree on
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
## UI/UX Squad Review — {goal}

### Senior UX Designer
{bullets}

### Senior Accessibility
{bullets}

### UI/UX Squad Position
{bullets from UX Lead}
---
```
```

- [ ] **Step 3: Commit**

```bash
git add plugins/uiux-squad/
git commit -m "feat: add uiux-squad standalone skill"
```

---

## Task 5: Deploy and verify

**Files:** none (deploy-skills.sh handles copies to `~/.claude/skills/`)

- [ ] **Step 1: Run deploy-skills.sh**

```bash
./deploy-skills.sh
```

Expected output (order may vary):
```
→ session-manager
→ squad-planning
→ stakeholder-acceptance
→ ui-components-refactor
→ dev-squad
→ uiux-squad
Done — 6 skill(s) deployed to /Users/djacomo/.claude/skills
```

- [ ] **Step 2: Verify all three skill files exist at their installed locations**

```bash
ls ~/.claude/skills/squad-planning/SKILL.md \
   ~/.claude/skills/dev-squad/SKILL.md \
   ~/.claude/skills/uiux-squad/SKILL.md
```

Expected: all three paths print without error.

- [ ] **Step 3: Spot-check v3 content in installed squad-planning**

```bash
grep -n "Heads Team\|Tavola Rotonda\|checkpoint\|Dev Squad\|UI/UX Squad" \
  ~/.claude/skills/squad-planning/SKILL.md | head -20
```

Expected: multiple matches across all five terms.

- [ ] **Step 4: Spot-check dev-squad and uiux-squad installed correctly**

```bash
grep -n "Dev Lead\|reconciliation" ~/.claude/skills/dev-squad/SKILL.md | head -5
grep -n "UX Lead\|reconciliation" ~/.claude/skills/uiux-squad/SKILL.md | head -5
```

Expected: matches in both files.

- [ ] **Step 5: Final commit**

```bash
git add -A
git status
```

Confirm nothing unexpected is staged, then:

```bash
git commit -m "chore: deploy squad-planning v3, dev-squad, uiux-squad" --allow-empty
```

(Use `--allow-empty` only if deploy-skills.sh output files are gitignored; otherwise stage normally.)

---

## Self-Review

**Spec coverage check:**

| Spec requirement | Task |
|---|---|
| Heads Team rename + two-tier | Task 1 |
| Tavola Rotonda Anchor+Response | Task 1 — Phase 1a/1b dispatch pattern |
| Checkpoint after every phase | Task 1 — Checkpoint Check + Dispatch Pattern |
| Resume on run start | Task 1 — Checkpoint Check section |
| Dev Squad mini round table | Task 1 (prompt templates) + Task 3 |
| UI/UX Squad mini round table | Task 1 (prompt templates) + Task 4 |
| Standalone /dev-squad skill | Task 3 |
| Standalone /uiux-squad skill | Task 4 |
| Squads share squad-profile.md | All three skills read same profile — no profile changes |
| plugin.json updated | Task 2 |
| deploy-skills.sh picks up new plugins | Task 5 — no script changes needed |

All requirements covered. No placeholders. Type/name consistency verified (Dev Lead, UX Lead, Phase 2a/2b used consistently across Task 1, 3, and 4).
