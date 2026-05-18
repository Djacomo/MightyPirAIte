---
name: stakeholder-acceptance
description: Post-implementation stakeholder review — AI compliance check against original requirements + human UAT click-through script. Run after implementation is complete, before marking a feature as shipped.
---

# Stakeholder Acceptance Review

## What this skill does

Runs two outputs per stakeholder, in parallel:

1. **Compliance check** — reads the implementation files and verifies each requirement the stakeholder raised during the squad review. Produces a pass/fail/partial table.
2. **UAT click-through script** — generates a structured step-by-step test script the human runs on the real page. The AI cannot see rendered UI; the human does the visual verification using this script.

**The AI does the systematic compliance check. The human does the visual click-through.**

---

## What you need before invoking

- Implementation is complete (all handoff tasks done)
- The original squad review is accessible (spec file, handoff file, or pasted text)
- You know which files were modified (or can run `git diff --name-only HEAD~1`)

---

## Invocation

```
/stakeholder-acceptance [feature name or short description]
```

On invocation, announce: **"Starting stakeholder acceptance review — gathering context."**

Then collect the following. If $ARGUMENTS provides a feature description, use it. Ask for anything missing:

> 1. **Feature** — what was built (one sentence, if not in $ARGUMENTS)
> 2. **Original squad review** — path to the spec or handoff file containing the stakeholder concerns from the squad review, OR paste the relevant block directly
> 3. **Implementation files** — paths to the files that were modified/created (tip: `git diff --name-only HEAD~1` or the handoff's file ownership section)
> 4. **Staging URL** *(optional)* — if a dev server is running, provide it; the UAT script will reference it directly

---

## Dispatch Pattern

1. Read `.claude/squad-profile.md` — load all stakeholder definitions
2. Read the squad review source provided by the user — extract the section for each stakeholder (their bullets, concerns, and pushback)
3. Run `git diff --name-only HEAD~1` (or use the user-provided list) to confirm implementation files
4. Dispatch all stakeholders **in parallel** as `Agent` calls (`subagent_type: "claude"`)
5. Each stakeholder receives: their profile + original concerns + implementation files to read + UAT script instructions
6. Synthesize into a final acceptance report

---

## Agent Prompt Template

```
You are simulating {stakeholder_name} for {project_name}. {stakeholder_description}

FEATURE BUILT: {feature}

YOUR ORIGINAL CONCERNS (from the squad review before implementation):
{original_concerns}

Read these implementation files: {implementation_files}

Produce "## {stakeholder_name} Acceptance Review" with two sections:

---

### Compliance Check

For each concern you raised originally, assess whether it was addressed in the implementation.
Read the files carefully — check templates, logic, labels, messages, and error handling.

| # | Original Concern | Status | Evidence |
|---|---|---|---|
| 1 | {concern text} | ✅ PASS / ❌ FAIL / ⚠️ PARTIAL | file:line or "not found" |
| 2 | ... | ... | ... |

Add any **new concerns** you notice in the implementation that were not in the original review — things that would affect your experience as {stakeholder_name}.

**Verdict:** READY FOR UAT / NOT READY (list blocking FAILs)

---

### UAT Click-Through Script

Write a step-by-step script a human can follow on the real page to verify this feature works from your perspective. You cannot see the rendered UI — the human will.

**Pre-conditions:** [system state needed before starting — e.g. "logged in as admin, at least one tournament exists"]

**Happy path:**
1. [Action] → Expected: [what the user should see/happen]
2. [Action] → Expected: [what the user should see/happen]
...

**Edge cases to verify:**
- [Scenario] → Expected: [what should happen]
- [Scenario] → Expected: [what should happen]

**What to watch for (from my perspective as {stakeholder_name}):**
- [specific concern about visual/UX that only a human can verify]
- [another concern]

---

{stakeholder_voice}
Keep your output focused. Max 10 compliance rows, max 12 UAT steps.
```

---

## Synthesis

After all stakeholder agents return, produce the **Acceptance Report**:

```markdown
---
## Acceptance Report — {feature}

### Summary
| Stakeholder | Verdict | Blocking issues |
|---|---|---|
| {Stakeholder 1} | ✅ READY / ❌ NOT READY | [none / list] |
| {Stakeholder 2} | ✅ READY / ❌ NOT READY | [none / list] |

**Overall: READY FOR UAT** — all stakeholders pass, run the scripts below.
**OR**
**Overall: NOT READY** — fix the following before UAT: [list blocking FAILs]

---

### {Stakeholder 1} — Compliance Check
{table from agent}

### {Stakeholder 1} — UAT Script
{script from agent}

---

### {Stakeholder 2} — Compliance Check
{table from agent}

### {Stakeholder 2} — UAT Script
{script from agent}

---

### Human UAT Instructions
1. Fix any NOT READY items first
2. Start a local or staging server
3. Run each UAT script above in order
4. Check off each step as you go
5. If a step fails, note the actual result and open a bug
6. Feature is accepted when all scripts pass and no blocking visual issues are found
---
```

---

## Boundaries — what this skill cannot do

- **Cannot see rendered UI** — labels, layout, and visual design must be verified by a human
- **Cannot test performance or responsiveness** — the UAT script will flag these as human-only checks
- **Cannot replace real user testing** — this is a structured starting point, not a substitute
- **Cannot access a running server** — if a staging URL is provided, it appears in the UAT script as a reference; the human navigates it

---

## Common Mistakes

| Mistake | Fix |
|---|---|
| Running before implementation is complete | This skill reviews finished code. Run it when the handoff done-criteria are met. |
| Not providing the original squad review | Without the original concerns, compliance check becomes generic and low-value. Always provide the squad review source. |
| Treating READY FOR UAT as shipped | READY means the AI compliance check passed. The human UAT script still needs to be run. |
| Skipping the UAT script | The click-through script is the human's job. Do not mark a feature as accepted without running it. |
| Providing too many implementation files | Focus on the files that changed. If in doubt, use `git diff --name-only HEAD~1`. |
