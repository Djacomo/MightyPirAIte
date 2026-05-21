# Squad Handoff Format

Use this file as the authoritative template for generating `.claude/squad-handoff.md` inside the repository at `.claude/squad-handoff-format.md`.

The purpose of the handoff is to make the result readable by the Head Team and implementation-oriented stakeholders **without forcing them to reconstruct the full codebase context from zero**.

---

## File Template

```markdown
# Squad Handoff — {goal}
_Date: {date} | Route: {route} | Type: {type} | Perspective: {perspective}_

## Request Summary
- Goal: {goal}
- Why now: {reason or trigger}
- Triggering context: {optional}

## Current Understanding
- Project snapshot: {short summary}
- Relevant memory state: {what from squad-memory matters right now}
- Relevant architecture context: {only what is needed}

## Findings
- {finding}
- {finding}
- {finding}

## Architectural Decisions
- {decision}
- {decision}

## Product Decisions
- {decision}
- {decision}

## Acceptance Criteria
- {criterion}
- {criterion}
- {criterion}

## Risks
| Risk | Severity | Why it matters | Mitigation |
|---|---|---|---|
| {risk} | high/medium/low | {why} | {mitigation} |

## Open Questions
- {question} | owner: {owner or unknown}
- {question} | owner: {owner or unknown}

## Suggested Task Breakdown
- {task 1}
- {task 2}
- {task 3}

## Suggested Next Sprint Scope
- {item} | priority: high/medium/low
- {item} | priority: high/medium/low

## Implementation Hook (Optional)
Use this section only if the user wants Option B downstream execution.

- Preferred execution path: {Claude Code / dev-squad / uiux-squad / human team}
- Execution brief: {short implementer-ready brief}
- Constraints to preserve: {must-not-break items}
- Memory update required after execution: yes
```

---

## Rules

- Keep the document scannable and synthesis-heavy.
- Do not dump raw agent outputs.
- Write for reusability by a Head Team that wants the outcome, not the full transcript.
- Keep architecture context concise; the handoff is not a replacement for the architecture file.
- If the route was light, keep the handoff proportionally light.
- If there are unresolved blockers, state them clearly.
