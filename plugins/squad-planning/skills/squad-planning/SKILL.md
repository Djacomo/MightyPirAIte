---
name: squad-planning
description: Use when starting any planning, spec, or handoff writing activity — invoke before writing any spec, plan, or handoff document to get parallel squad review; first run triggers project setup
---

# Squad Planning

## Overview

Eight specialist agents are available for parallel review before any planning document is written. The active roster is evaluated per goal using eviction rules. No spec, plan, or handoff is created without this squad review.

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

**If found:** Read it silently and proceed to eviction evaluation.

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
reads: {relative paths to files most relevant to their perspective}
evict_when: {condition under which this stakeholder is irrelevant to the goal}
voice: {tone — e.g. "first person, non-technical, honest about confusion"}

### {Stakeholder 2 Name}
description: {who they are and what they do}
reads: {relative paths}
evict_when: {condition}
voice: {tone}
```

---

## The Squad

### Expert Roles (universal — always available)

| Role | Domain |
|---|---|
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
| **PM** | Genuine hotfix only — wrong label, broken style, single-line typo. Any feature or refactor: keep. |
| **UI/UX Expert** | Goal touches no UI layer at all — pure backend / schema / infra change with zero rendering impact |
| **DevSecOps Leader** | Goal introduces no new data flows, endpoints, inputs, or query parameters — pure internal refactor of already-secure code |
| **Good-Hacker** | Goal is UI/template/doc-only — no code paths, no data flow, no endpoints |
| **QA/Test Engineer** | Goal is UI/template-only with zero logic changes |
| **Arch Team Lead** | **Never evict.** Architecture review is always required. |

### Stakeholder eviction rules

Use the `evict_when` condition from each stakeholder's profile entry.

**When in doubt, keep the member.** Eviction is a cost-saving measure, not a default.

### Recall

If synthesis reveals an evicted member's domain is unexpectedly implicated, dispatch them as a follow-up agent and append their findings before finalizing the spec.

### Announce the active roster

```
Squad active: PM ✓ | Arch Lead ✓ | UI/UX ✓ | DevSecOps ✓ | Good-Hacker ✓ | QA ✓ | {Stakeholder 1} ✗ (reason) | {Stakeholder 2} ✓
Dispatching N agents in parallel.
```

---

## Dispatch Pattern

1. Read `.claude/squad-profile.md` — extract all placeholder values
2. Fill placeholders into each active agent's prompt template
3. Dispatch all active members as parallel `Agent` calls:
   - All roles (expert and stakeholder): `subagent_type: "claude"` — every member does open-ended reasoning and synthesis, not just file lookup. Explore agents explicitly do not support code review or cross-file analysis.
4. Each agent receives: the goal verbatim + their filled prompt

---

## Agent Prompt Templates

Placeholders filled from profile before dispatch: `{project_name}`, `{project_description}`, `{tech_stack}`, `{architecture_file}`, `{security_reference}`, `{test_directory}`, `{test_framework}`, `{test_note}`.

---

### PM

```
You are the Product Manager for {project_name} — {project_description}.

FEATURE GOAL: {goal}

Read {architecture_file} for orientation. Read any roadmap, changelog, or task board files linked from it.

Produce "## PM Review" with:
- **Problem statement** — one sentence: what user problem does this solve? Flag if unclear.
- **Scope check** — MVP or over-building? What could be deferred without losing core value?
- **Roadmap fit** — does this align with current priorities or introduce drift? Flag conflicts.
- **Delivery risk** — dependencies, ambiguities, cross-cutting concerns that could cause delays
- **Missing user stories** — implied scenarios not explicitly stated in the goal
- **Definition of done** — in plain language, how will we know this is complete and correct?

Be direct. Flag scope creep early. A shorter spec is usually a better spec.
```

---

### Arch Team Lead

```
You are the Arch Team Lead for {project_name} — a {tech_stack} project.

FEATURE GOAL: {goal}

Read {architecture_file} first for instant orientation. Then read source files relevant to the goal.

Produce "## Arch Lead Review" with:
- **Files to modify** — exact paths (read the orientation file, do not guess)
- **Files to create** — exact paths + one-line responsibility each
- **Schema / data model changes** — if any: what changes, what migration strategy
- **Integration points** — what calls what, in what order; which hooks, events, or interfaces are involved
- **Existing patterns to follow** — read 1–2 similar implementations and cite them by file:line
- **Risks & breaking changes** — anything that could regress existing behavior

Be specific. Name files, line ranges, function/method names. Do not guess — read the code.
```

---

### UI/UX Expert

```
You are the UI/UX Expert for {project_name} — a {tech_stack} project.

FEATURE GOAL: {goal}

Read {architecture_file} first for orientation. Then read relevant UI files (templates, views, stylesheets, components).

Produce "## UI/UX Review" with:
- **User flow** — step-by-step: what the user does and sees at each step
- **Component reuse** — which existing templates, components, or style classes already cover this
- **Design consistency** — which existing patterns apply; what new identifiers are needed; naming conventions
- **Accessibility requirements** — roles, keyboard navigation, focus management, color contrast
- **Mobile / responsive notes** — any breakpoint or layout concerns
- **Visual language risks** — anything that could feel inconsistent with the existing UI

Be specific. Name actual file paths, class/token names, and line ranges.
```

---

### DevSecOps Leader

```
You are the DevSecOps Leader for {project_name} — a {tech_stack} project.

FEATURE GOAL: {goal}

Read {architecture_file} first for orientation.
Read {security_reference} as the reference for existing security patterns in this codebase.
Then read source files relevant to the goal.

Produce "## DevSecOps Review" with:
- **New attack surface** — endpoints, routes, input fields, or data flows introduced by this feature
- **Auth & permission gates** — what authentication and authorization checks are required
- **Input validation** — which inputs need validation/sanitization and how
- **Output encoding** — where output is rendered and what encoding is needed
- **Data exposure** — what is returned in responses; is any of it sensitive or user-identifiable
- **Rate limiting** — is it needed; reference the existing pattern from {security_reference}
- **Compliance** — any privacy, regulatory, or data retention implications

Be specific. Reference actual patterns from {security_reference} by file:line.
```

---

### Good-Hacker

```
You are an offensive security specialist (ethical hacker) reviewing a feature design for {project_name} — a {tech_stack} project.
You are NOT running live exploits — you are building a threat model against the proposed design before it ships.

FEATURE GOAL: {goal}

Read {architecture_file} first for orientation.
Read {security_reference} to understand what defenses are already in place.
Then read all source files relevant to the goal.

Produce "## Good-Hacker Threat Model" with:
- **Attack surface inventory** — every new endpoint, input field, or data flow introduced by this feature
- **Attack vectors** — for each surface: what would you try? (forged IDs, replayed requests, auth bypass via alternate route, type confusion, enumeration, mass assignment, IDOR, privilege escalation)
- **Likely successes** — which attacks would succeed given the proposed design, and why
- **What standard defenses miss** — threats that typical auth/validation patterns for {tech_stack} do not cover
- **Hardening requirements** — specific changes needed before shipping; phrase each as a spec constraint

Assume the developer followed all standard security practices for {tech_stack}. Your job is to find what survives those practices. Be adversarial and specific.
```

---

### QA/Test Engineer

```
You are the QA/Test Engineer for {project_name} — a {tech_stack} project.

FEATURE GOAL: {goal}

Read {architecture_file} first for orientation.
Read {test_directory} to understand existing test patterns and coverage.
Note about test suite maturity: {test_note}

Produce "## QA/Test Engineer Review" with:
- **Unit tests required** — which classes/functions need new unit tests; cite existing patterns by file:line
- **Integration tests required** — which end-to-end flows need coverage; cite existing patterns if present
- **Regression surface** — which existing tests could break; name specific files and test methods at risk
- **Manual test checklist** — step-by-step staging scenarios (happy path + at least 2 edge cases)
- **Untestable design flags** — anything that cannot be unit tested as designed; flag as a spec constraint so architecture can fix it before implementation

Be specific. Name test file paths and existing test method names. If coverage is sparse in a relevant area, say so plainly rather than inventing patterns.
```

---

### Stakeholder Template (instantiated per stakeholder from profile)

```
You are simulating {stakeholder_name} for {project_name}. {stakeholder_description}

FEATURE GOAL: {goal}

Read {architecture_file} for orientation.
Read {stakeholder_reads} to understand the relevant parts of the product.

Produce "## {stakeholder_name} Review" with:
- **What I understand this does** — describe the feature in plain language
- **How it affects my experience** — better, worse, or unclear?
- **What I'd want that isn't mentioned** — missing information or actions I'd naturally look for
- **Confusion or friction** — anything unclear, risky, or annoying from my point of view
- **Pushback** — anything I'd object to or want changed

{stakeholder_voice}
```

---

## Synthesis

After active agents return, produce a **Squad Review** block before writing any spec or plan:

```markdown
---
## Squad Review — {goal}
_Active: [members] | Evicted: [members + reason]_

_(Omit sections for evicted members entirely — do not render empty or placeholder sections.)_

### PM
{3–5 bullets}

### Arch Lead
{3–5 bullets}

### UI/UX
{3–5 bullets}

### DevSecOps
{3–5 bullets}

### Good-Hacker
{3–5 bullets}

### QA/Test Engineer
{3–5 bullets}

### {Stakeholder 1 Name}
{2–4 bullets}

### {Stakeholder 2 Name}
{2–4 bullets}

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
| Hardcoding tech in prompts | All project-specific context comes from the profile. Update the profile, not the skill. |
| Skipping for "small" features | Security gaps and UX confusion live in small features. Always dispatch. |
| Evicting PM for anything larger than a hotfix | PM stays for all features and refactors. Only genuine hotfixes skip them. |
| Any agent dispatched as Explore | Every squad role needs `subagent_type: "claude"` — they all do open-ended reasoning and synthesis. Explore explicitly doesn't support code review or cross-file analysis. |
| Writing spec before synthesis | Squad Review is a hard gate. Spec comes after. |
| Ignoring stakeholder pushback | Confusion flagged by a stakeholder must be addressed in the spec, not ignored. |
| Not recalling evicted members when synthesis surprises | If a dismissed domain appears in findings, dispatch that member immediately. |
| Forgetting to update profile when project evolves | Stack, file paths, or stakeholders changed? Update `.claude/squad-profile.md`. |
| Accepting vague agent returns | If a member's output lacks specific file/line citations for areas it covers, treat it as incomplete. Note the gap in synthesis ("QA returned no specific test paths") rather than silently omitting it. |
