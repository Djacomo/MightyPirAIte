---
name: squad-planning
description: Use when starting any planning, spec, or handoff writing activity — invoke before writing any spec, plan, or handoff document to get parallel squad review; first run triggers project setup
---

# Squad Planning

## Overview

Eight specialist agents plus an AI Expert are available for parallel review before any planning document is written. The squad operates in **two phases**: a serial AI Expert pre-flight that creates a targeted dispatch plan, then a parallel squad review using that plan. No spec, plan, or handoff is created without this squad review.

**This skill is project-agnostic.** All project-specific context (tech stack, file paths, stakeholder definitions) lives in `.claude/squad-profile.md`. Agent prompts use `{placeholders}` filled from that file at dispatch time.

**Announce at start:** "Activating squad: reading project profile — evaluating roster."

---

## First Run — Question Time

Check whether `.claude/squad-profile.md` exists in the project root.

**If missing:** Run Question Time before doing anything else. Ask the user the following in a single conversation turn:

> 1. **Project identity** — Name and one-sentence description of what it does.
> 2. **Tech stack** — Language, framework, and key libraries.
> 3. **Stakeholders** — Who are the end users? For each type: name, what they do, what makes their perspective unique. (1–4 stakeholders. These become the Stakeholder slots in the squad.)
> 4. **Architecture file** — Path to the file that gives instant codebase orientation (e.g. PROJECT_MAP.md, README, CONTEXT.md).
> 5. **Security reference** — Path to an existing file showing correct auth/permission patterns (e.g. an existing handler). Say "none" if absent.
> 6. **Test infrastructure** — Test directory path, framework name, and whether the suite is mature or sparse.

Then write `.claude/squad-profile.md` using the template below and confirm: **"Profile saved. Squad is ready."**

**If found:** Read it silently and proceed to Phase 0.

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
test_note: {maturity note — e.g. "suite is sparse, flag gaps explicitly"}

## Stakeholders

### {Stakeholder 1 Name}
description: {who they are and what they do}
reads: {absolute paths to files most relevant to their perspective}
evict_when: {condition under which this stakeholder is irrelevant to the goal}
voice: {tone — e.g. "first person, non-technical, honest about confusion"}

### {Stakeholder 2 Name}
description: {who they are and what they do}
reads: {absolute paths}
evict_when: {condition}
voice: {tone}
```

---

## The Squad

### Expert Roles (universal — always available)

| Role | Domain |
|---|---|
| **AI Expert** | Phase 0 pre-flight — analyzes goal, plans targeted dispatch: who to evict, per-agent file list, output budgets, what to pre-summarize |
| **PM** | Product scope, MVP definition, delivery risk, roadmap fit, user story clarity, over-engineering detection |
| **Arch Team Lead** | File ownership, data model, schema migrations, integration points, existing patterns, breaking changes |
| **UI/UX Expert** | User flow, component reuse, design consistency, accessibility, mobile, visual language |
| **DevSecOps Leader** | Auth/permission gates, input validation, output encoding, data exposure, rate limiting, compliance |
| **Good-Hacker** | Offensive threat model — attack vectors, bypass attempts, enumeration, what survives DevSecOps defenses |
| **QA/Test Engineer** | Unit test strategy, integration coverage, regression surface, manual test checklist, untestable design flags |

### Stakeholder Slots (from profile)

Loaded at runtime from `.claude/squad-profile.md`. Each defined stakeholder becomes a squad member with its own eviction rule.

---

## Squad Membership — Evict & Recall

Before dispatching, read the goal and evaluate each member. Announce the active roster with evictions explained.

### Expert eviction rules

| Member | Evict when |
|---|---|
| **AI Expert** | **Never evict.** Always runs as Phase 0 before squad dispatch. |
| **Arch Team Lead** | **Never evict.** Architecture review is always required. |
| **PM** | Genuine hotfix only — wrong label, broken style, single-line typo. Any feature or refactor: keep. |
| **UI/UX Expert** | Goal touches no UI layer at all — pure backend / schema / infra change with zero rendering impact |
| **DevSecOps Leader** | Goal introduces no new data flows, endpoints, inputs, or query parameters — pure internal refactor of already-secure code |
| **Good-Hacker** | Goal is UI/template/doc-only — no code paths, no data flow, no endpoints |
| **QA/Test Engineer** | Goal is UI/template-only with zero logic changes |

### Stakeholder eviction rules

Use the `evict_when` condition from each stakeholder's profile entry.

**When in doubt, keep the member.** Eviction is a cost-saving measure, not a default.

### Recall

If synthesis reveals an evicted member's domain is unexpectedly implicated, dispatch them as a follow-up agent and append their findings before finalizing the spec.

### Announce the active roster

```
Phase 0: AI Expert dispatched.
Phase 1 roster: PM ✓ | Arch Lead ✓ | UI/UX ✓ | DevSecOps ✓ | Good-Hacker ✓ | QA ✓ | {Stakeholder 1} ✗ (reason) | {Stakeholder 2} ✓
Dispatching N agents in parallel.
```

---

## Dispatch Pattern

### Phase 0 — AI Expert Pre-flight (serial)

1. Read `.claude/squad-profile.md` — extract all placeholder values
2. Dispatch **AI Expert alone** as a single foreground `Agent` call (`subagent_type: "claude"`)
3. AI Expert returns a Dispatch Plan: active roster + per-agent file list + output budgets + pre-summarize list
4. **Orchestrator pre-flight** — read each file flagged for pre-summarization (never more than 2 files):
   - `{arch_summary}`: 200–300 word extract covering project structure, key modules, and anything in the architecture file relevant to the goal
   - `{security_summary}`: 100–150 word extract of auth/permission patterns from the security reference (only if DevSecOps or Good-Hacker are active; omit if `security_reference` is "none")
5. Apply evictions from the AI Expert's plan. Announce the Phase 1 roster.

### Phase 1 — Squad Dispatch (parallel)

6. For each active agent, build their prompt from the template by:
   - Filling `{arch_summary}` and `{security_summary}` with the pre-read summaries
   - Filling `{specific_files}` with the AI Expert's file list for that agent (1–3 files)
   - Filling `{output_budget}` with the token budget from the AI Expert's plan
7. Dispatch all active agents as parallel `Agent` calls (`subagent_type: "claude"`)
8. Each agent receives: the goal verbatim + their filled prompt

---

## Agent Prompt Templates

### Placeholders

Filled from profile: `{project_name}`, `{project_description}`, `{tech_stack}`, `{test_directory}`, `{test_framework}`, `{test_note}`.

Filled from AI Expert's dispatch plan:
- `{arch_summary}` — pre-read architecture summary (200–300 words, created by orchestrator)
- `{security_summary}` — pre-read security patterns summary (100–150 words, created by orchestrator)
- `{specific_files}` — per-agent file list, 1–3 files (varies by agent)
- `{output_budget}` — token budget for this agent's entire output

---

### AI Expert

```
You are the AI Efficiency Expert for {project_name} — {project_description}.

FEATURE GOAL: {goal}

Read `.claude/squad-profile.md` for full squad and project context. Do not read any other files — your job is to plan the review, not do it.

Create a targeted dispatch plan that maximizes review quality while eliminating token waste. Be aggressive with evictions — a focused 4-agent review beats an 8-agent one where half the agents read the same files and produce noise.

Produce "## Dispatch Plan":

### Active Roster
List each squad member: ✓ (keep) or ✗ (evict + one-line reason).
Evict when less than 50% chance the member surfaces something the others won't.

### Pre-Summarize
Files the orchestrator reads ONCE and injects as context. Agents will not read these themselves.
- architecture file → arch_summary (always include)
- security reference → security_summary (only if DevSecOps or Good-Hacker are active; skip if "none")

### Per-Agent File List
For each active agent: 1–3 specific files to read beyond the injected summaries.
Use exact paths from the profile. Write "orchestrator judgment" if the profile doesn't give you enough to decide.

| Agent | Files to read |
|---|---|
| PM | (none — arch_summary sufficient) |
| Arch Lead | [path], [path] |
| UI/UX | [path] |
| DevSecOps | [path] |
| Good-Hacker | [path] |
| QA | [test_file], [test_file] |
| {Stakeholder} | [path] |

### Output Budgets
Pick one complexity tier and apply it to all active agents:

| Tier | When | Arch | Security agents | PM | Others |
|---|---|---|---|---|---|
| Simple | 1–2 files, no new endpoints | 400t | 350t | 250t | 250t |
| Medium | 2–4 files, one new endpoint | 600t | 500t | 300t | 300t |
| Complex | schema changes, multiple endpoints | 700t | 600t | 350t | 400t |

State the tier and list the budget for each active agent.
```

---

### PM

```
You are the Product Manager for {project_name} — {project_description}.

FEATURE GOAL: {goal}

PROJECT CONTEXT (pre-read — do not re-read the architecture file):
{arch_summary}

Produce "## PM Review" with:
- **Problem statement** — one sentence: what user problem does this solve? Flag if unclear.
- **Scope check** — MVP or over-building? What could be deferred without losing core value?
- **Roadmap fit** — does this align with current priorities or introduce drift? Flag conflicts.
- **Delivery risk** — dependencies, ambiguities, cross-cutting concerns that could cause delays
- **Missing user stories** — implied scenarios not explicitly stated in the goal
- **Definition of done** — in plain language, how will we know this is complete and correct?

Be direct. Flag scope creep early. A shorter spec is usually a better spec.
**Output budget: {output_budget} tokens total. Max 4 bullets per section, one sentence each.**
```

---

### Arch Team Lead

```
You are the Arch Team Lead for {project_name} — a {tech_stack} project.

FEATURE GOAL: {goal}

PROJECT CONTEXT (pre-read — do not re-read the architecture file):
{arch_summary}

Read these specific files only: {specific_files}

Produce "## Arch Lead Review" with:
- **Files to modify** — exact paths
- **Files to create** — exact paths + one-line responsibility each
- **Schema / data model changes** — if any: what changes, what migration strategy
- **Integration points** — what calls what, in what order; which hooks, events, or interfaces are involved
- **Existing patterns to follow** — cite by file:line from the files you read
- **Risks & breaking changes** — anything that could regress existing behavior

Be specific. Name files, line ranges, function/method names. Do not read beyond {specific_files}.
**Output budget: {output_budget} tokens total. Max 4 bullets per section, one sentence each.**
```

---

### UI/UX Expert

```
You are the UI/UX Expert for {project_name} — a {tech_stack} project.

FEATURE GOAL: {goal}

PROJECT CONTEXT (pre-read — do not re-read the architecture file):
{arch_summary}

Read these specific files only: {specific_files}

Produce "## UI/UX Review" with:
- **User flow** — step-by-step: what the user does and sees at each step
- **Component reuse** — which existing templates, components, or style classes already cover this
- **Design consistency** — which existing patterns apply; what new identifiers are needed; naming conventions
- **Accessibility requirements** — roles, keyboard navigation, focus management, color contrast
- **Mobile / responsive notes** — any breakpoint or layout concerns
- **Visual language risks** — anything that could feel inconsistent with the existing UI

Be specific. Name actual file paths, class/token names, and line ranges. Do not read beyond {specific_files}.
**Output budget: {output_budget} tokens total. Max 4 bullets per section, one sentence each.**
```

---

### DevSecOps Leader

```
You are the DevSecOps Leader for {project_name} — a {tech_stack} project.

FEATURE GOAL: {goal}

PROJECT CONTEXT (pre-read — do not re-read the architecture file):
{arch_summary}

SECURITY PATTERNS (pre-read — do not re-read the security reference file):
{security_summary}

Read these specific files only: {specific_files}

Produce "## DevSecOps Review" with:
- **New attack surface** — endpoints, routes, input fields, or data flows introduced by this feature
- **Auth & permission gates** — what authentication and authorization checks are required
- **Input validation** — which inputs need validation/sanitization and how
- **Output encoding** — where output is rendered and what encoding is needed
- **Data exposure** — what is returned in responses; is any of it sensitive or user-identifiable
- **Rate limiting** — is it needed; cite the existing pattern from the security summary above
- **Compliance** — any privacy, regulatory, or data retention implications

Be specific. Cite file:line for any patterns referenced. Do not read beyond {specific_files}.
**Output budget: {output_budget} tokens total. Max 4 bullets per section, one sentence each.**
```

---

### Good-Hacker

```
You are an offensive security specialist (ethical hacker) reviewing a feature design for {project_name} — a {tech_stack} project.
You are NOT running live exploits — you are building a threat model against the proposed design before it ships.

FEATURE GOAL: {goal}

PROJECT CONTEXT (pre-read — do not re-read the architecture file):
{arch_summary}

EXISTING DEFENSES (pre-read — do not re-read the security reference file):
{security_summary}

Read these specific files only: {specific_files}

Produce "## Good-Hacker Threat Model" with:
- **Attack surface inventory** — every new endpoint, input field, or data flow introduced by this feature
- **Attack vectors** — for each surface: what would you try? (forged IDs, replayed requests, auth bypass, type confusion, enumeration, IDOR, privilege escalation)
- **Likely successes** — which attacks would succeed given the proposed design, and why
- **What standard defenses miss** — threats that typical {tech_stack} patterns do not cover
- **Hardening requirements** — specific changes needed before shipping; phrase each as a spec constraint

Assume standard {tech_stack} security practices are in place. Find what survives them. Do not read beyond {specific_files}.
**Output budget: {output_budget} tokens total. Max 4 bullets per section, one sentence each.**
```

---

### QA/Test Engineer

```
You are the QA/Test Engineer for {project_name} — a {tech_stack} project.

FEATURE GOAL: {goal}

PROJECT CONTEXT (pre-read — do not re-read the architecture file):
{arch_summary}

Read these specific files only: {specific_files}
Note about test suite maturity: {test_note}

Produce "## QA/Test Engineer Review" with:
- **Unit tests required** — which classes/functions need new unit tests; cite existing patterns by file:line
- **Integration tests required** — which end-to-end flows need coverage; cite existing patterns if present
- **Regression surface** — which existing tests could break; name specific files and test methods at risk
- **Manual test checklist** — happy path + 2 edge cases (3 scenarios max)
- **Untestable design flags** — anything that cannot be unit tested as designed; flag as a spec constraint

Be specific. Name test file paths and existing test method names. Do not read beyond {specific_files}.
**Output budget: {output_budget} tokens total. Max 4 bullets per section, one sentence each.**
```

---

### Stakeholder Template (instantiated per stakeholder from profile)

```
You are simulating {stakeholder_name} for {project_name}. {stakeholder_description}

FEATURE GOAL: {goal}

PROJECT CONTEXT (pre-read — do not re-read the architecture file):
{arch_summary}

Read these specific files only: {specific_files}

Produce "## {stakeholder_name} Review" with:
- **What I understand this does** — describe the feature in plain language
- **How it affects my experience** — better, worse, or unclear?
- **What I'd want that isn't mentioned** — missing information or actions I'd naturally look for
- **Confusion or friction** — anything unclear, risky, or annoying from my point of view
- **Pushback** — anything I'd object to or want changed

{stakeholder_voice}
**Output budget: {output_budget} tokens total. Max 3 bullets per section, one sentence each.**
```

---

## Synthesis

After active agents return, produce a **Squad Review** block before writing any spec or plan:

```markdown
---
## Squad Review — {goal}
_Active: [members] | Evicted: [members + reason] | Tier: [Simple/Medium/Complex]_

_(Omit sections for evicted members entirely — do not render empty or placeholder sections.)_

### PM
{3–4 bullets}

### Arch Lead
{3–4 bullets}

### UI/UX
{3–4 bullets}

### DevSecOps
{3–4 bullets}

### Good-Hacker
{3–4 bullets}

### QA/Test Engineer
{3–4 bullets}

### {Stakeholder 1 Name}
{2–3 bullets}

### {Stakeholder 2 Name}
{2–3 bullets}

### Conflicts & Tensions
- {member A} says {X} — {member B} says {Y}: resolution needed before spec is finalized
- _(omit section if none)_

**BLOCKER:** If any conflict requires a product or architectural decision beyond Claude's authority,
stop here and ask the user before writing the spec.

### Synthesis — Hard Constraints for the Spec
- {binding constraint from any domain}
- {binding constraint}
- ...
---
```

The spec is written **after** this block. Every hard constraint becomes a non-negotiable requirement in the spec.

---

## Common Mistakes

| Mistake | Fix |
|---|---|
| Running without a profile | Always check for `.claude/squad-profile.md` first. Missing = run Question Time. |
| Skipping Phase 0 to save time | Phase 0 costs ~500 tokens and saves 5–10× that in Phase 1. Never skip it. |
| Hardcoding tech in prompts | All project-specific context comes from the profile. Update the profile, not the skill. |
| Skipping for "small" features | Security gaps and UX confusion live in small features. Always dispatch. |
| Evicting PM for anything larger than a hotfix | PM stays for all features and refactors. Only genuine hotfixes skip them. |
| Any agent dispatched as Explore | Every squad role needs `subagent_type: "claude"` — they all do open-ended reasoning and synthesis. |
| Writing spec before synthesis | Squad Review is a hard gate. Spec comes after. |
| Ignoring stakeholder pushback | Confusion flagged by a stakeholder must be addressed in the spec, not ignored. |
| Not recalling evicted members when synthesis surprises | If a dismissed domain appears in findings, dispatch that member immediately. |
| Forgetting to update profile when project evolves | Stack, file paths, or stakeholders changed? Update `.claude/squad-profile.md`. |
| Accepting vague agent returns | If a member's output lacks specific file/line citations, note the gap in synthesis rather than silently omitting it. |
| Agents reading beyond their specific_files list | Agents must read only what the AI Expert prescribed. Unrestricted reads are the primary source of token waste. |
| Injecting full file contents instead of summaries | arch_summary and security_summary must be compact (200–300 words). Dumping full file content defeats the purpose. |
| AI Expert reading source files | AI Expert reads only squad-profile.md. It plans the review — it does not do it. |
