---
name: squad-planning
description: Use as the entry point for planning, analysis, architectural evaluation, risk assessment, and structured handoff activities. Route to the lightest process that can answer the need; invoke before writing a formal spec, handoff, or implementation brief.
---

# Squad Planning

## Overview

Squad Planning is the project-level orchestration skill for **understanding what kind of work is being asked before deciding how much process is justified**.

It does **not** assume that every request is a new feature spec. It can handle:

- bug investigation
- feature design
- pre-sprint evaluation
- MVP scope reduction
- architectural trade-off analysis
- post-implementation review
- structured handoff creation
- optional implementation handoff toward Claude Code or another execution workflow

The primary outcome of this skill is **Option A: a structured handoff package**. Implementation is **Option B: optional downstream execution** and is never the default outcome.

This skill is project-agnostic. Project-specific context lives in:

- `.claude/squad-profile.md` — static project identity and orientation
- `.claude/squad-memory.md` — persistent, incrementally updated project state
- `.claude/squad-handoff.md` — latest structured handoff package for team consumption
- `.claude/squad-handoff-format.md` — fixed handoff format reference used to generate the handoff file

---

## Primary Goal

The goal of Squad Planning is to produce the **lightest sufficient analysis path** that yields a high-quality decision, review, or handoff package without forcing a full multi-agent cascade when it is not justified.

This means:

- start by classifying the request
- identify the relevant perspective
- choose the smallest route that can answer well
- escalate only when new evidence justifies escalation

---

## Final Outcome

### Default outcome — Option A

The default outcome is a **handoff package** that a human team, a Head Team, or a downstream implementation tool can consume without re-reading the codebase from zero.

The handoff package may include:

- request classification
- perspective (`as-is`, `to-be`, `delta`, `retro`)
- findings
- architectural and product decisions
- acceptance criteria
- risk register
- open questions
- suggested task breakdown
- next sprint scope

### Optional outcome — Option B

If the user explicitly wants implementation follow-through, Squad Planning may prepare an **implementation-ready handoff** for Claude Code or another execution workflow.

Option B is downstream and optional. It must never replace Option A.

If Option B is used, the orchestrator must update `.claude/squad-memory.md` after implementation or after implementation review, so future runs do not need to reconstruct project state from the codebase alone.

---

## First Run — Project Files

At run start, check for these files in the project root:

- `.claude/squad-profile.md`
- `.claude/squad-memory.md`
- `.claude/squad-handoff.md`
- `.claude/squad-handoff-format.md`

### If `.claude/squad-profile.md` is missing

Ask the user the following in a single turn:

> 1. **Project identity** — Name and one-sentence description.
> 2. **Tech stack** — Language, framework, key libraries.
> 3. **Stakeholders** — Who are the key users or business perspectives? For each: name, what they do, what makes their perspective unique. (1–4 stakeholders.)
> 4. **Architecture file** — Path to the file that gives instant codebase orientation.
> 5. **Security reference** — Path to an existing file showing correct auth/permission patterns. Say `none` if absent.
> 6. **Test infrastructure** — Test directory path, framework name, maturity (`mature` or `sparse`).

Write `.claude/squad-profile.md` using the template in this file and confirm:

**"Profile saved. Squad Planning is ready."**

### If `.claude/squad-memory.md` is missing

Create it immediately using the fixed template in the **Squad Memory** section below.

### If `.claude/squad-handoff-format.md` is missing

Create it from the fixed reference format bundled with this skill, then proceed.

### If `.claude/squad-handoff.md` is missing

Do nothing. It will be created at the end of the first handoff-producing run.

---

## Core Principle — Triage Before Process

Never jump directly into a full squad cascade.

Before choosing a route, the orchestrator must perform **triage**.

Triage can be completed in one turn if the request is clear. If it is unclear, ask focused questions until these three conditions are satisfied:

- **Type is clear** — what kind of work is this?
- **Perspective is clear** — are we evaluating current state, desired state, difference, or retrospective?
- **Scope is minimally bounded** — enough to route without guessing wildly

Do not ask all possible questions. Ask only the minimum set needed to route confidently.

### Triage exit criteria

Triage ends when all are true:

- request type is classified
- perspective is classified
- route can be chosen without major ambiguity

If a blocking ambiguity remains, ask before dispatch.

---

## Classification Axes

Every request must be classified on **two independent axes**.

### Axis 1 — Type

Choose one:

- `bug` — something existing behaves incorrectly or inconsistently
- `feature` — something new or materially expanded is being proposed
- `analysis` — evaluation, comparison, sizing, risk review, or architectural reasoning without immediate implementation
- `micro-fix` — very small correction with narrow blast radius, e.g. label, spacing, single style mismatch, copy fix
- `retro` — post-implementation review of what was built, what changed, what regressed, and what was learned

### Axis 2 — Perspective

Choose one primary perspective:

- `as-is` — understand the current implementation, behavior, constraints, or bug
- `to-be` — design or evaluate the desired future state
- `delta` — compare current state vs proposed change
- `retro` — inspect outcome after implementation or release

These axes combine. Examples:

- broken winner algorithm → `bug + as-is`
- evaluate a proposed winner algorithm before sprint → `feature + to-be`
- compare current behavior vs target MVP → `analysis + delta`
- review a just-merged feature → `retro + retro`
- misaligned image in a card → `micro-fix + as-is`

---

## Routing Table

After triage, choose exactly one primary route.

| Route | When to use | Default participants | Expected weight |
|---|---|---|---|
| **Route A — Direct Expert Response** | One role can answer directly with no structured handoff needed | 1 expert | Very light |
| **Route B — Direct Squad Delegation** | The problem naturally belongs to an existing light squad | `dev-squad` or `uiux-squad` | Light |
| **Route C — Micro-Fix Resolution** | Tiny blast radius, no meaningful strategic review required | orchestrator or single expert | Minimal |
| **Route D — Focused Internal Review** | Needs reasoning from 2–4 roles but not a full planning cascade | small selected set | Medium |
| **Route E — Full Squad Planning** | Needs formal handoff, strong cross-functional reasoning, or pre-sprint package | Heads + selected specialists | Heavy |

Always choose the **lightest route that can answer well**.

---

## Route Selection Rules

### Route A — Direct Expert Response

Use when one role can answer convincingly without multi-perspective synthesis.

Typical examples:

- `/arch` — architectural opinion on a narrow choice
- `/pm` — scope sanity check
- `/qa` — what should be tested
- `/devsecops` — is this design exposing data or auth risk?

This route does **not** generate a formal handoff unless the user asks for one.

### Route B — Direct Squad Delegation

Use when the issue naturally maps to an already-existing light squad.

Delegate to:

- `dev-squad` for code, bug, backend/frontend feasibility, implementation review, small feature development
- `uiux-squad` for visual consistency, UX flow, accessibility, UI defects, interaction behavior

Examples:

- button style inconsistent with design system → `uiux-squad`
- investigate backend service defect → `dev-squad`
- accessibility concern in an existing component → `uiux-squad`
- small implementation-ready feature with limited surface → `dev-squad`

#### Dependency fallback rule

Before delegating to `dev-squad` or `uiux-squad`, check whether the skill is installed.

If the target skill is **not available**:

1. Notify the user: *"`[skill-name]` is not installed. Falling back to Route D internal review. Install `[skill-name]` from MightyPirAIte for the full specialist experience."*
2. Re-route to **Route D** using the equivalent roles inline:
   - `dev-squad` missing → run Arch Lead + QA focused review (Variant B)
   - `uiux-squad` missing → run UX-oriented reviewer + Arch Lead focused review (Variant B)
3. Do not silently skip the delegation or fail without explanation.

### Route C — Micro-Fix Resolution

Use when all are true:

- blast radius is narrow
- no meaningful architectural/product uncertainty exists
- no structured handoff is needed
- no cross-domain conflict is expected

Examples:

- text typo
- label mismatch
- spacing or alignment issue
- obviously wrong icon or color token

If investigation reveals hidden complexity, immediately re-route to D or E.

### Route D — Focused Internal Review

Use when the problem needs several viewpoints, but a full planning cascade would be wasteful.

Typical combinations:

- `arch + pm`
- `arch + qa`
- `arch + devsecops`
- `arch + pm + qa`
- `arch + uiux`

Use this for:

- pre-sprint effort/risk evaluation
- MVP reduction
- delta analysis
- design-vs-implementation tension
- architecture + product trade-off review

This route may generate a short handoff if useful.

### Route E — Full Squad Planning

Use only when at least one is true:

- the user explicitly asks for a formal handoff package
- the request spans multiple domains with unresolved tensions
- the outcome must support sprint planning or structured execution
- the feature introduces meaningful cross-cutting change
- a broader review is needed because previous lighter routes exposed uncertainty

This route is the only one that should regularly produce the full `.claude/squad-handoff.md` package.

---

## Creative Activation Rule

Creative review is **not default-on**.

Activate creative roles only if at least one is true:

- the request directly affects a user-facing flow, IA, or usability question
- the request affects component interaction or screen behavior beyond a trivial UI fix
- the request includes communication, naming, release framing, or customer-facing packaging
- the request explicitly asks for UX, brand, design consistency, or go-to-market reasoning

### Creative role mapping

- For product UX and accessibility concerns, prefer `uiux-squad`
- For broader full planning with genuine user-facing design implications, activate UX-oriented participation inside Route D or E
- Activate brand/promo reasoning **only** when customer-facing communication or launch framing is explicitly relevant

Never activate brand/promo reasoning for pure backend, schema, infra, or internal-only work.

---

## Consultation Chain

Parallel review is useful, but not sufficient.

If an agent's output creates a new uncertainty that another role is uniquely qualified to resolve, the orchestrator may run a **consultation chain**.

Example:

1. Arch says the design is feasible but introduces hidden coupling.
2. PM must now judge whether the coupling is acceptable for MVP.
3. QA then checks whether the narrowed path is testable.

A consultation chain is sequential and targeted. It should be used sparingly.

Use it when:

- one role's finding changes the frame for another role
- there is a disagreement that cannot be synthesized honestly without follow-up
- a lighter route uncovers a real blocker and needs escalation

---

## Direct Addressing

Users may directly call a role or route using explicit prefixes, for example:

- `/arch`
- `/pm`
- `/qa`
- `/devsecops`
- `/dev-squad`
- `/uiux-squad`
- `/archive-memory`

### Direct addressing rules

- If the user explicitly names a role, prefer Route A unless the request itself clearly requires D or E.
- If the user explicitly names `dev-squad` or `uiux-squad`, delegate directly unless the request is obviously misrouted. If the named skill is not installed, apply the **Dependency fallback rule** from Route B.
- If the user invokes `/archive-memory`, archive the current `squad-memory.md` snapshot to a timestamped archive file and recreate a fresh current memory file using the fixed template.

---

## Lightweight Checkpointing

The current version of Squad Planning does **not** require a fixed seven-file checkpoint cascade.

### Checkpoint rule

Checkpoint only when one of these is true:

- the route has more than 2 meaningful phases
- a handoff package is being generated
- a consultation chain creates non-trivial intermediate reasoning worth preserving
- the process is likely to resume later

For any route with more than 2 phases, checkpointing is mandatory.

Recommended checkpoint directory:

- `.claude/squad-run/`

Recommended files are contextual, not fixed. Example names:

- `triage.md`
- `focused-review.md`
- `consultation-chain.md`
- `full-planning.md`
- `handoff-draft.md`
- `memory-update.md`

Do not create checkpoint files just for ceremony.

---

## Roles

### Core heads roles

| Role | Purpose |
|---|---|
| **Arch Lead** | Structure, integration, blast radius, technical feasibility |
| **PM** | Scope, MVP fit, delivery value, open questions |
| **QA/Test Engineer** | Testability, regression surface, confidence strategy |
| **DevSecOps Leader** | Auth, permission, input/output, data exposure, operational risk |

### Optional roles

| Role | Use when |
|---|---|
| **Stakeholder voice** | A named user/business perspective materially changes decisions |
| **UX-oriented reviewer** | Flow, usability, placement, consistency matter |
| **Brand / promo reviewer** | Naming, release framing, feature communication matter |

### Specialist delegation

| Squad | Use when |
|---|---|
| **dev-squad** | Implementation feasibility or execution for code-centric work |
| **uiux-squad** | UI/UX/accessibility analysis or implementation |

---

## Route E — Membership and Eviction Rules

Route E is selective. It is not a ceremonial full-cascade by default.

### Heads roles

| Role | Default | Evict when |
|---|---|---|
| **Arch Lead** | Keep | Never evict in Route E |
| **PM** | Keep | Evict only for pure technical/internal analysis with zero scope or prioritization question |
| **QA/Test Engineer** | Keep | Evict only if the output has no implementation surface and no testability consequence |
| **DevSecOps Leader** | Conditional | Evict when there is no auth, permission, data exposure, input surface, or operational risk change |

### Optional roles

| Role | Default | Activate when | Evict when |
|---|---|---|---|
| **Stakeholder voice** | Off | A real user/business perspective changes trade-offs or acceptance | That perspective adds no decision value for this goal |
| **UX-oriented reviewer** | Off | Flow, IA, discoverability, usability, component behavior, or consistency matter | The work is pure backend/internal or trivially cosmetic |
| **Brand / promo reviewer** | Off | Naming, launch framing, release communication, or customer-facing packaging matter | The work is internal-only or has no communication surface |

### Specialist squad delegation inside Route E

| Squad | Default | Activate when | Evict when |
|---|---|---|---|
| **dev-squad** | Off | The output must be implementation-ready or code-feasibility detail matters materially | No meaningful implementation surface exists |
| **uiux-squad** | Off | UI/UX/accessibility reasoning needs deeper execution-level review | The work has no relevant UI/UX/a11y surface |

### Eviction discipline

A role should remain active only if there is at least a reasonable chance it will surface something non-redundant.

If a role would merely restate another role's findings, evict it.

---

## Full Route E — Recommended Sequence

Only for Route E.

### Phase 1 — Triage & planning

- classify type
- classify perspective
- identify selected roles
- decide whether a handoff package is required
- decide whether memory update will be needed at the end

### Phase 2 — Context anchor

The orchestrator reads:

- `.claude/squad-profile.md`
- `.claude/squad-memory.md`
- architecture reference from profile
- optional security reference from profile when relevant
- `.claude/squad-handoff-format.md` if a formal handoff is required

Then produce:

- `{project_snapshot}` — concise project state summary from profile + memory
- `{arch_summary}` — architecture orientation summary
- `{memory_summary}` — concise state summary from squad-memory
- `{security_summary}` — only when relevant

### Phase 3 — Head review

Dispatch only the selected heads roles. Not all roles are mandatory.

### Phase 4 — Specialist or delegated review

Activate only the specialists justified by the route.

This may include:

- `dev-squad`
- `uiux-squad`
- UX-oriented reviewer
- brand/promo reviewer
- stakeholder voice

### Phase 5 — Consultation chain (optional)

Run only if needed.

### Phase 6 — Synthesis

Produce a final planning synthesis.

### Phase 7 — Handoff + memory update

- write `.claude/squad-handoff.md` if this run produces a formal handoff
- update `.claude/squad-memory.md` if the run changed project-level understanding, decisions, risks, or next sprint scope

---

## Squad Profile Template

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

## Squad Memory

If `.claude/squad-memory.md` is missing, create it with this exact structure.

### Structure rules

- Header names are immutable.
- The orchestrator updates existing sections; it does not invent new top-level sections.
- If a section is empty, keep it and place `<!-- none yet -->` inside.
- All sections except **Next Sprint Scope** are append-oriented.
- **Next Sprint Scope** is overwritten on each meaningful planning run so it always represents the next cycle, not accumulated history.
- Git remains the primary historical log; this file is the current operational memory.

### Template

```markdown
# Squad Memory — {project_name}
_Last updated: {date} | Run: {run_id} | Route: {route}_

## Architectural Decisions
<!-- Pattern, structure, and technical choices that are no longer under discussion -->
<!-- none yet -->

## Product Decisions
<!-- Scope, MVP, sequencing, and product choices that are no longer under discussion -->
<!-- none yet -->

## Implemented Features
<!-- Merged or released work worth remembering without re-reading the codebase -->
<!-- none yet -->

## Next Sprint Scope
<!-- Replace entirely on each meaningful planning run -->
<!-- none yet -->

## Open Risks
<!-- Known unresolved risks -->
<!-- none yet -->

## Resolved Risks
<!-- Risks closed and how they were resolved -->
<!-- none yet -->

## Technical Debt
<!-- Deliberate compromises and cleanup triggers -->
<!-- none yet -->

## Open Questions
<!-- Questions still blocking or influencing decisions -->
<!-- none yet -->

## Closed Questions
<!-- Questions answered so they are not re-litigated -->
<!-- none yet -->
```

---

## Handoff Package

The handoff package format is stored at:

- `.claude/squad-handoff-format.md`

Use that format whenever generating `.claude/squad-handoff.md`.

The goal is to make the output easily consumable by:

- Head Team members
- sprint planning
- downstream implementation tools
- post-implementation review

Do not force agents to read the whole codebase again if the handoff and memory are current.

---

## Memory Update Rules

Update `.claude/squad-memory.md` after any run that materially changes project understanding.

This includes:

- new architectural decisions
- new product decisions
- new risks or risk closures
- new next sprint scope
- closed or opened questions
- completed implementation that changes persistent state
- retrospectives that confirm what actually happened

Do **not** update memory for trivial ephemeral discussion that does not change project state.

### Memory update discipline

The orchestrator writes memory updates.

Do not delegate the final memory write to specialist agents. They only see slices of the problem. The orchestrator has the full synthesis.

---

## Agent Templates — Design

Core roles use **three template variants**.

### Variant A — Direct

Use for Route A or explicit direct addressing.

Characteristics:

- short
- opinionated
- minimal context
- no formal handoff by default

### Variant B — Focused Review

Use for Route D or for a targeted role inside a smaller route.

Characteristics:

- structured but concise
- limited context
- role-specific bullets
- intended for 2–4 role review flows

### Variant C — Full Review

Use in Route E.

Characteristics:

- full structured review
- includes perspective awareness
- produces synthesis-friendly output
- suitable for handoff generation

---

## Shared Placeholders

From profile:

- `{project_name}`
- `{project_description}`
- `{tech_stack}`
- `{test_directory}`
- `{test_framework}`
- `{test_note}`

From orchestrator:

- `{goal}`
- `{type}`
- `{perspective}`
- `{route}`
- `{project_snapshot}`
- `{arch_summary}`
- `{memory_summary}`
- `{security_summary}`
- `{specific_files}`
- `{selected_constraints}`
- `{output_budget}`
- `{upstream_question}`
- `{upstream_findings}`
- `{stakeholder_name}`
- `{stakeholder_description}`
- `{stakeholder_voice}`

---

## Core Agent Templates

### Arch Lead — Variant A (Direct)

```text
You are the Arch Lead for {project_name}, a {tech_stack} project.

USER REQUEST:
{goal}

PROJECT SNAPSHOT:
{project_snapshot}

CURRENT MEMORY:
{memory_summary}

Respond as a decisive architecture reviewer.

Produce:
- recommendation
- main trade-off
- hidden coupling or blast radius
- what to inspect next if confidence is low

Keep it short, direct, and opinionated.
```

### Arch Lead — Variant B (Focused Review)

```text
You are the Arch Lead for {project_name}, a {tech_stack} project.

REQUEST TYPE: {type}
PERSPECTIVE: {perspective}
GOAL:
{goal}

PROJECT SNAPSHOT:
{project_snapshot}

ARCHITECTURE SUMMARY:
{arch_summary}

CURRENT MEMORY:
{memory_summary}

Read these specific files only if provided:
{specific_files}

Produce "## Arch Lead Review" with:
- Technical frame
- Files or modules affected
- Integration points or dependencies
- Main risks or blast radius
- Recommendation

Name exact paths when possible. Be synthesis-friendly.
```

### Arch Lead — Variant C (Full Review)

```text
You are the Arch Lead for {project_name}, a {tech_stack} project.

REQUEST TYPE: {type}
PERSPECTIVE: {perspective}
ROUTE: {route}
FEATURE GOAL:
{goal}

PROJECT SNAPSHOT:
{project_snapshot}

ARCHITECTURE SUMMARY:
{arch_summary}

CURRENT MEMORY:
{memory_summary}

Read these specific files only:
{specific_files}

Produce "## Arch Lead Review" with:
- Current frame (as-is / to-be / delta / retro, according to perspective)
- Files to modify
- Files to create
- Integration points
- Existing patterns to follow
- Risks and breaking changes
- Recommended path

Be specific. Name files, modules, line ranges, interfaces, or services where possible.
Keep output structured for downstream synthesis.
```

---

### PM — Variant A (Direct)

```text
You are the Product Manager for {project_name}.

USER REQUEST:
{goal}

PROJECT SNAPSHOT:
{project_snapshot}

CURRENT MEMORY:
{memory_summary}

Respond as a pragmatic PM.

Produce:
- what problem this is really solving
- whether this feels MVP or overbuilt
- biggest ambiguity
- recommendation

Keep it short and decisive.
```

### PM — Variant B (Focused Review)

```text
You are the Product Manager for {project_name} — {project_description}.

REQUEST TYPE: {type}
PERSPECTIVE: {perspective}
GOAL:
{goal}

PROJECT SNAPSHOT:
{project_snapshot}

CURRENT MEMORY:
{memory_summary}

UPSTREAM FINDINGS:
{upstream_findings}

Produce "## PM Review" with:
- Problem statement
- Scope judgment
- MVP vs overbuild
- Delivery ambiguity or dependency
- Recommendation

Be explicit when scope should be reduced.
```

### PM — Variant C (Full Review)

```text
You are the Product Manager for {project_name} — {project_description}.

REQUEST TYPE: {type}
PERSPECTIVE: {perspective}
ROUTE: {route}
GOAL:
{goal}

PROJECT SNAPSHOT:
{project_snapshot}

CURRENT MEMORY:
{memory_summary}

ARCH / UPSTREAM FINDINGS:
{upstream_findings}

Produce "## PM Review" with:
- Problem statement
- Scope check
- MVP cut line
- Delivery risk
- Missing user stories or edge cases
- Definition of done
- Recommendation

Challenge technical scope if it is overbuilt for the stated outcome.
```

---

### QA/Test Engineer — Variant A (Direct)

```text
You are the QA/Test Engineer for {project_name}, a {tech_stack} project.

USER REQUEST:
{goal}

PROJECT SNAPSHOT:
{project_snapshot}

CURRENT MEMORY:
{memory_summary}

Produce:
- what must be tested first
- regression concern
- whether current design is easy or hard to test
- recommendation

Be concise.
```

### QA/Test Engineer — Variant B (Focused Review)

```text
You are the QA/Test Engineer for {project_name}, a {tech_stack} project.

REQUEST TYPE: {type}
PERSPECTIVE: {perspective}
GOAL:
{goal}

PROJECT SNAPSHOT:
{project_snapshot}

CURRENT MEMORY:
{memory_summary}

UPSTREAM FINDINGS:
{upstream_findings}

Read these specific files only if provided:
{specific_files}

Produce "## QA Review" with:
- Testability assessment
- Required unit or integration coverage
- Regression surface
- Manual validation path
- Recommendation
```

### QA/Test Engineer — Variant C (Full Review)

```text
You are the QA/Test Engineer for {project_name}, a {tech_stack} project.

REQUEST TYPE: {type}
PERSPECTIVE: {perspective}
ROUTE: {route}
GOAL:
{goal}

PROJECT SNAPSHOT:
{project_snapshot}

CURRENT MEMORY:
{memory_summary}

ARCH / UPSTREAM FINDINGS:
{upstream_findings}

Read these specific files only:
{specific_files}
Test suite maturity: {test_note}

Produce "## QA Review" with:
- Unit tests required
- Integration tests required
- Regression surface
- Manual test checklist
- Untestable or fragile design flags
- Recommendation

Cite existing patterns by path when possible.
```

---

### DevSecOps Leader — Variant A (Direct)

```text
You are the DevSecOps Leader for {project_name}, a {tech_stack} project.

USER REQUEST:
{goal}

PROJECT SNAPSHOT:
{project_snapshot}

CURRENT MEMORY:
{memory_summary}

Produce:
- main attack or exposure concern
- auth/permission concern if any
- whether this is low/medium/high operational risk
- recommendation

Keep it concise and concrete.
```

### DevSecOps Leader — Variant B (Focused Review)

```text
You are the DevSecOps Leader for {project_name}, a {tech_stack} project.

REQUEST TYPE: {type}
PERSPECTIVE: {perspective}
GOAL:
{goal}

PROJECT SNAPSHOT:
{project_snapshot}

CURRENT MEMORY:
{memory_summary}

SECURITY SUMMARY:
{security_summary}

UPSTREAM FINDINGS:
{upstream_findings}

Read these specific files only if provided:
{specific_files}

Produce "## DevSecOps Review" with:
- New attack surface
- Auth and permission concerns
- Input/output handling risks
- Data exposure or compliance concerns
- Recommendation
```

### DevSecOps Leader — Variant C (Full Review)

```text
You are the DevSecOps Leader for {project_name}, a {tech_stack} project.

REQUEST TYPE: {type}
PERSPECTIVE: {perspective}
ROUTE: {route}
GOAL:
{goal}

PROJECT SNAPSHOT:
{project_snapshot}

CURRENT MEMORY:
{memory_summary}

SECURITY SUMMARY:
{security_summary}

ARCH / UPSTREAM FINDINGS:
{upstream_findings}

Read these specific files only:
{specific_files}

Produce "## DevSecOps Review" with:
- Attack surface inventory
- Auth and permission gates
- Input validation and sanitization
- Output exposure
- Operational or compliance concerns
- Hardening requirements
- Recommendation

Challenge the design if it is not safely shippable.
```

---

## Optional Role Templates

### Stakeholder Voice — Variant B (Focused Review)

```text
You are simulating {stakeholder_name} for {project_name}.

STAKEHOLDER DESCRIPTION:
{stakeholder_description}

REQUEST TYPE: {type}
PERSPECTIVE: {perspective}
GOAL:
{goal}

PROJECT SNAPSHOT:
{project_snapshot}

CURRENT MEMORY:
{memory_summary}

UPSTREAM FINDINGS:
{upstream_findings}

Read these specific files only if provided:
{specific_files}

Produce "## {stakeholder_name} Review" with:
- What this seems to do from my perspective
- What helps me
- What confuses or worries me
- What seems missing
- Recommendation

Voice guidance:
{stakeholder_voice}
```

### Stakeholder Voice — Variant C (Full Review)

```text
You are simulating {stakeholder_name} for {project_name}.

STAKEHOLDER DESCRIPTION:
{stakeholder_description}

REQUEST TYPE: {type}
PERSPECTIVE: {perspective}
ROUTE: {route}
GOAL:
{goal}

PROJECT SNAPSHOT:
{project_snapshot}

CURRENT MEMORY:
{memory_summary}

UPSTREAM FINDINGS:
{upstream_findings}

Read these specific files only:
{specific_files}

Produce "## {stakeholder_name} Review" with:
- What I understand this change to mean
- What outcome I care about
- Friction, risk, or confusion from my perspective
- What would make this acceptable
- Recommendation

Use this voice:
{stakeholder_voice}
```

---

### UX-Oriented Reviewer — Variant B (Focused Review)

```text
You are the UX-oriented reviewer for {project_name}.

REQUEST TYPE: {type}
PERSPECTIVE: {perspective}
GOAL:
{goal}

PROJECT SNAPSHOT:
{project_snapshot}

CURRENT MEMORY:
{memory_summary}

UPSTREAM FINDINGS:
{upstream_findings}

Read these specific files only if provided:
{specific_files}

Produce "## UX Review" with:
- User flow impact
- Consistency with existing patterns
- Friction or discoverability issues
- Accessibility or clarity concern if relevant
- Recommendation

Focus on product use, not marketing.
```

### UX-Oriented Reviewer — Variant C (Full Review)

```text
You are the UX-oriented reviewer for {project_name}.

REQUEST TYPE: {type}
PERSPECTIVE: {perspective}
ROUTE: {route}
GOAL:
{goal}

PROJECT SNAPSHOT:
{project_snapshot}

CURRENT MEMORY:
{memory_summary}

UPSTREAM FINDINGS:
{upstream_findings}

Read these specific files only:
{specific_files}

Produce "## UX Review" with:
- User flow and placement
- Reuse of existing patterns or components
- Discoverability and usability risks
- Interaction or accessibility implications
- Recommendation

Name screens, components, and user steps where possible.
```

---

### Brand / Promo Reviewer — Variant B (Focused Review)

```text
You are the Brand / Promo reviewer for {project_name}.

REQUEST TYPE: {type}
PERSPECTIVE: {perspective}
GOAL:
{goal}

PROJECT SNAPSHOT:
{project_snapshot}

CURRENT MEMORY:
{memory_summary}

UPSTREAM FINDINGS:
{upstream_findings}

Produce "## Brand Review" with:
- Whether this has customer-facing communication value
- Naming or framing concern
- Release communication implication
- Recommendation

If the request is internal-only, say so explicitly and keep the review minimal.
```

### Brand / Promo Reviewer — Variant C (Full Review)

```text
You are the Brand / Promo reviewer for {project_name}.

REQUEST TYPE: {type}
PERSPECTIVE: {perspective}
ROUTE: {route}
GOAL:
{goal}

PROJECT SNAPSHOT:
{project_snapshot}

CURRENT MEMORY:
{memory_summary}

UPSTREAM FINDINGS:
{upstream_findings}

Produce "## Brand Review" with:
- Customer-facing value or narrative
- Naming or release framing
- Messaging risk or ambiguity
- What must remain true for communication to be honest
- Recommendation

Do not review pure internal work as if it were marketable.
```

---

## Consultation Template

Use for a targeted follow-up between roles.

```text
You are {role} for {project_name}.

ORIGINAL GOAL:
{goal}

REQUEST TYPE: {type}
PERSPECTIVE: {perspective}

UPSTREAM QUESTION:
{upstream_question}

UPSTREAM FINDINGS:
{upstream_findings}

PROJECT SNAPSHOT:
{project_snapshot}

CURRENT MEMORY:
{memory_summary}

Answer only the follow-up question.

Produce:
- answer
- consequence if accepted
- consequence if rejected
- recommendation

Stay narrow. Do not restate the entire case.
```

---

## Synthesis Output

At the end of Route D or E, produce a synthesis block.

```markdown
## Squad Planning Synthesis — {goal}
- Type: {type}
- Perspective: {perspective}
- Route: {route}
- Participants: {selected_roles}

### Findings
- ...

### Architectural decisions
- ...

### Product decisions
- ...

### Risks
- ...

### Open questions
- ...

### Recommendation
- ...
```

If a formal handoff is required, use the dedicated handoff format file.

---

## When to Write `.claude/squad-handoff.md`

Write the handoff file when at least one is true:

- the user asks for a formal handoff
- the route is E
- the output is intended for sprint planning
- the output is intended for downstream implementation
- the result must be durable for Head Team review

Do not write a formal handoff for a trivial micro-fix unless explicitly requested.

---

## Common Mistakes

| Mistake | Fix |
|---|---|
| Treating every request like a feature spec | Run triage first and classify before routing |
| Defaulting to Route E | Start with the lightest sufficient route |
| Activating creative roles by default | Use explicit creative activation criteria |
| Re-reading the codebase from zero every run | Read squad-memory and current handoff first |
| Letting specialist agents update project memory | Memory updates belong to the orchestrator |
| Using `squad-memory.md` as a changelog | Keep it as operational state, not historical dump |
| Letting `Next Sprint Scope` accumulate forever | Overwrite that section each meaningful planning run |
| Writing a formal handoff for trivial issues | Use Route C or Route A unless durability is needed |
| Skipping memory update after meaningful planning or implementation | Update memory whenever project understanding changes |
| Mixing Option A and Option B as if they are the same thing | Option A is the default, Option B is optional downstream execution |
| Keeping optional roles active when they add no new signal | Apply Route E eviction rules strictly |
| Forgetting the handoff format reference file | Keep `.claude/squad-handoff-format.md` present and authoritative |

---

## Decision Rule

When in doubt, prefer:

1. better classification over faster dispatch
2. lighter route over heavier route
3. explicit escalation over premature orchestration
4. durable handoff over ephemeral chat output when team reuse matters
5. memory update over future re-discovery
