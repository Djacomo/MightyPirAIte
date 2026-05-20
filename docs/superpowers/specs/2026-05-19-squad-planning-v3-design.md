# Squad Planning v3 — Design Spec

_Date: 2026-05-19_

## Overview

Three skills replace the current single `squad-planning` skill:

| Skill | When to use |
|---|---|
| `/squad-planning` | Full feature specs, architectural changes, security-sensitive work |
| `/dev-squad` | Bug fixes, small features, implementation questions — Dev focus |
| `/uiux-squad` | UI tweaks, flow questions, accessibility fixes — Design focus |

All three share the same `squad-profile.md` and checkpoint directory.

---

## Two-Tier Architecture

```
Tier 1 — Heads Team     Strategic, cross-cutting, produces the "Heads Brief"
Tier 2 — Specialist Squads   Receive the Brief, go deep in their domain
```

The Heads Team is the renamed current squad. It runs Phase 0 + Phase 1 of a full cascade.
Specialist squads receive the Heads Brief and do their own internal Tavola Rotonda.

---

## Squad Compositions

### Heads Team (Tier 1)

| Role | Anchor? | Eviction rule |
|---|---|---|
| AI Expert | Phase 0 (serial) | Never evict |
| Arch Team Lead | Yes — runs alone first | Never evict |
| PM | No | Genuine hotfix only |
| DevSecOps Leader | No | No new data flows or endpoints |
| Good-Hacker | No | UI/template/doc-only changes |
| QA/Test Engineer | No | UI/template-only, zero logic changes |
| Stakeholders (from profile) | No | Per `evict_when` in profile |

### Dev Squad (Tier 2)

| Role | Phase |
|---|---|
| Senior Backend Engineer | Phase 2a — parallel |
| Senior Frontend Engineer | Phase 2a — parallel |
| Dev Lead | Phase 2b — reconciliation (reads both 2a outputs) |

### UI/UX Squad (Tier 2)

| Role | Phase |
|---|---|
| Senior UX Designer | Phase 2a — parallel |
| Senior Accessibility Engineer | Phase 2a — parallel |
| UX Lead | Phase 2b — reconciliation (reads both 2a outputs) |

---

## Full Cascade — `/squad-planning`

### Phase 0 — AI Expert (serial)
- Reads `squad-profile.md` only
- Produces dispatch plan: active roster, per-agent file lists, output budgets, pre-summarize list
- **Checkpoint:** `.claude/squad-run/dispatch-plan.md`

### Phase 1 — Heads Team (Tavola Rotonda: Anchor + Response)

**Phase 1a — Arch Lead (solo)**
- Reads architecture file + specific files from dispatch plan
- Produces arch anchor output
- **Checkpoint:** `.claude/squad-run/arch-anchor.md`

**Phase 1b — Heads Team parallel**
- PM, DevSecOps, Good-Hacker, QA dispatched in parallel
- Each receives `arch-anchor.md` injected as text (not re-read)
- Stakeholders dispatched if not evicted
- **Checkpoint:** `.claude/squad-run/heads-brief.md` (orchestrator compresses all 1b outputs to ~400 tokens)

### Phase 2 — Specialist Squads (parallel squads, sequential within each)

**Dev Squad and UI/UX Squad run in parallel with each other.**

**Dev Squad internal flow:**
1. Phase 2a: Senior Backend + Senior Frontend in parallel (both receive `heads-brief.md`)
2. Phase 2b: Dev Lead alone (receives both 2a outputs) → unified position
- **Checkpoint:** `.claude/squad-run/dev-squad.md`

**UI/UX Squad internal flow:**
1. Phase 2a: Senior UX Designer + Senior Accessibility in parallel (both receive `heads-brief.md`)
2. Phase 2b: UX Lead alone (receives both 2a outputs) → unified position
- **Checkpoint:** `.claude/squad-run/uiux-squad.md`

### Synthesis
- Reads all checkpoint files: `dispatch-plan.md`, `arch-anchor.md`, `heads-brief.md`, `dev-squad.md`, `uiux-squad.md`
- Produces Squad Review block (same format as current skill)
- **Checkpoint:** `.claude/squad-run/synthesis.md`

---

## Standalone Squads — `/dev-squad` and `/uiux-squad`

For bugs, small features, and focused questions. No Heads Team phase.

**Flow:**
1. Read `squad-profile.md`
2. Orchestrator reads architecture file → produces `arch_summary` (200–300 words)
3. Squad Phase 2a: two seniors in parallel (both receive `arch_summary` + goal)
4. Squad Phase 2b: lead alone (receives both outputs) → unified position
5. Produce Squad Review block (dev or uiux section only)

No checkpointing for standalone runs (3 agents, fast enough to restart).

---

## Checkpoint / Resume System

**Directory:** `.claude/squad-run/` (project root)

**Files:**

| File | Written after |
|---|---|
| `dispatch-plan.md` | Phase 0 |
| `arch-anchor.md` | Phase 1a |
| `heads-brief.md` | Phase 1b |
| `dev-squad.md` | Dev Squad Phase 2b |
| `uiux-squad.md` | UI/UX Squad Phase 2b |
| `synthesis.md` | Final synthesis |

**On run start:** orchestrator checks each file in order. Existing files are restored; missing files trigger dispatch of that phase.

**Resume message format:**
```
Resuming squad run.
✓ Phase 0 restored  (dispatch-plan.md)
✓ Phase 1a restored (arch-anchor.md)
↻ Phase 1b dispatching — no checkpoint found
```

**Clearing a run:** user deletes `.claude/squad-run/` to start fresh.

---

## Token Budget Estimates

| Mode | Agents | Approx. input tokens | Approx. output tokens |
|---|---|---|---|
| Full cascade | 10–13 | 8,000–14,000 | 3,000–6,000 |
| Heads Team only (no squads) | 6–8 | 5,000–9,000 | 2,000–4,000 |
| Dev Squad standalone | 3 | 1,500–3,000 | 600–1,200 |
| UI/UX Squad standalone | 3 | 1,500–3,000 | 600–1,200 |

The checkpoint system ensures that in a token-exhaustion scenario, only the in-progress phase is lost. Completed phases resume at zero cost.

---

## Files to Create / Modify

| File | Action |
|---|---|
| `/Users/djacomo/.claude/skills/squad-planning/SKILL.md` | Rewrite — add Heads Team rename, two-tier architecture, checkpoint system |
| `/Users/djacomo/.claude/skills/dev-squad/SKILL.md` | Create new |
| `/Users/djacomo/.claude/skills/uiux-squad/SKILL.md` | Create new |
| `manifest.yml` (squad-planning) | Update description |
| `manifest.yml` (dev-squad) | Create |
| `manifest.yml` (uiux-squad) | Create |

---

## Hard Constraints

- Checkpoints are written before each phase dispatches the next — never after
- Standalone squads never trigger a Heads Team run
- Dev Lead and UX Lead always run after their team members, never in parallel with them
- `arch-anchor.md` is injected as text, not re-read by Phase 1b agents
- `heads-brief.md` is a ~400-token compression of all Phase 1 outputs — not a dump
- All three skills share the same `squad-profile.md` format — no profile changes needed
