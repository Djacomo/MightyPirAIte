# ⚓ VISION.md — The Mighty PirAIte Manifesto

> *"The ocean of AI is vast, noisy, and full of wrecks.*
> *We are the ship that knows where to sail."*

---

## Why this exists

Every developer working with Claude Code faces the same problem: the ocean is full of
guides, prompts, and "how to use AI" posts — but no solid reference point.

Most resources are:
- Blog posts that go stale in weeks
- Prompt collections with zero quality bar
- Tools that work for one specific setup and break everywhere else
- Content written for managers, not for people who actually ship code

**MightyPirAIte is built by developers, for developers.**
From the most junior dev finding their sea legs, to the architect who's been navigating
these waters for years.

No noise. No magic. No black boxes.
You read the `SKILL.md`, you know exactly what Claude Code will do.

---

## Who we serve

**Our crew** — in order of priority:

| Role | What they need from us |
|---|---|
| Junior Developer | Guardrails, patterns, confidence to ship |
| Mid-level Developer | Shortcuts, best practices, less boilerplate |
| Senior Developer | Depth, composability, architecture patterns |
| Architect | System-level tools, decision frameworks |

**Who we do NOT serve:** managers, consultants, and people who want to *talk about* AI
without writing a single line of code.

---

## What we ship

MightyPirAIte is a **open marketplace** of Claude Code tools, organized into four types:

### 🧠 Skills
Focused prompt workflows invoked via `/skill-name` inside Claude Code.
Each skill has a defined scope, input, output, and does one thing well.

### 🔌 MCP Configurations
Ready-to-use Model Context Protocol configurations for connecting Claude Code
to external services — GitHub, Supabase, databases, APIs, and more.
Plug in, configure secrets, go.

### ⚙️ CLI Tools
Shell scripts and automation tools that work alongside Claude Code.
Setup scripts, bootstrap tools, environment verifiers.

### 📋 CLAUDE.md Templates
Project-specific context files that give Claude Code memory and direction.
One per project type — Flutter, iOS, Android, React, backend, and more.

---

## The standard — our moat

Every contribution to MightyPirAIte **must** declare:

```yaml
name: my-tool-name
type: skill | mcp | cli | template
stack: flutter | ios | android | react | react-native | vue | angular |
       html-css | node | python | java | kotlin | scala | php |
       docker | kubernetes | github-actions | terraform |
       supabase | firebase | postgresql | mysql | any
level: junior | mid | senior | architect | any
claude-code-version: ">=1.0.0"
tested-on: macOS | Linux | Windows
```

**No undeclared stack. No untested tools. No vague descriptions.**

This standard is what separates MightyPirAIte from a random collection of gists.
It is the reason developers trust what they install from here.

A stack is added to the registry only when a contribution uses it.
Empty categories do not exist in this marketplace.

---

## Design language

The ship has its own colors. Every document, README, and UI element follows these tokens:

| Token | Value | Role |
|---|---|---|
| `--color-bg` | `#0A1628` | Deep ocean — background |
| `--color-text` | `#E8EDF5` | Starlight — primary text |
| `--color-primary` | `#F0C040` | Pirate Gold — accent, titles, CTAs |
| `--color-secondary` | `#2A6EA6` | Caribbean Blue — links, borders |
| `--color-fun` | `#C8860A` | Guinness Amber — quotes, notes |
| `--color-warn` | `#E63946` | Sheldon Red — warnings, callouts |

Voice: direct, technical, occasionally a pirate metaphor. Never corporate. Never fluffy.

---

## Roadmap philosophy

We ship in milestones, not sprints. Each milestone is a version of the ship —
more capable than the last, but always seaworthy.

| Milestone | Goal |
|---|---|
| `v0.1 — Raise the anchor` | Solid foundation: structure, standards, contributing guide |
| `v0.2 — First crew` | Core skills and templates across main stacks |
| `v0.3 — Navigation charts` | MCP configurations library |
| `v0.4 — The CLI` | Installer and bootstrap tool for fresh machines |
| `v1.0 — Open waters` | Community launch, full documentation, stable API |

---

## Community rules

1. **Ship working tools.** No half-finished contributions.
2. **Write for the reader.** Your `SKILL.md` is documentation, not a diary.
3. **No stack wars.** Flutter and React both sail this ship.
4. **Credit the crew.** Attribution matters in open source.
5. **Break it in a branch.** `main` is always seaworthy.

---

## License

MIT — use it, fork it, ship it. Keep the copyright line.

*© Djacomo — Mighty PirAIte*
