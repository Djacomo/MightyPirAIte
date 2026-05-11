# ⚓ Mighty PirAIte

[![version](https://img.shields.io/badge/version-1.0.0-F0C040?style=flat-square&labelColor=0A1628)](https://github.com/Djacomo/MightyPirAIte/releases)
[![license](https://img.shields.io/badge/license-MIT-2A6EA6?style=flat-square&labelColor=0A1628)](./LICENSE)
[![Claude Code](https://img.shields.io/badge/Claude_Code-tools-F0C040?style=flat-square&labelColor=0A1628)](https://claude.ai/code)
[![by Djacomo](https://img.shields.io/badge/by-Djacomo-E8EDF5?style=flat-square&labelColor=0A1628)](https://github.com/Djacomo)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-C8860A?style=flat-square&labelColor=0A1628)](./CONTRIBUTING.md)

*"I am Djacomo, Mighty PirAIte!"*

> The open marketplace for developers who navigate with Claude Code.
> From junior to architect — no noise, no magic, no black boxes.

---

## What is this

The ocean of AI tools is vast and full of wrecks.
Blog posts go stale. Prompt collections have no quality bar. Most resources are written for people who talk about code, not people who ship it.

**MightyPirAIte is the ship that knows where to sail.**

A curated, open marketplace of Claude Code tools — skills, MCP configurations, CLI scripts, and project templates — built by developers, reviewed by developers, and held to a standard that makes them actually trustworthy.

Every tool declares:
- What it does and what it does **not** do
- Which stack and level it targets
- **What it costs you** — including every external dependency

You read the manifest, you know exactly what you're installing.

---

## What's in the hold

| Type | What it is | Invoked by |
|---|---|---|
| 🧠 **Skill** | Focused prompt workflow for a specific task | `/skill-name` in Claude Code |
| 🔌 **MCP** | Ready-to-use Model Context Protocol config | Claude Code settings |
| ⚙️ **CLI** | Shell script or automation tool | Terminal |
| 📋 **Template** | `CLAUDE.md` for a specific project type | Drop in repo root |

---

## The crew — who this is for

| Role | What you get |
|---|---|
| **Junior Developer** | Guardrails, patterns, confidence to ship |
| **Mid-level Developer** | Shortcuts, best practices, less boilerplate |
| **Senior Developer** | Depth, composability, architecture patterns |
| **Architect** | System-level tools, decision frameworks |

If you write code, you belong here.

---

## Registry

### 🧠 Skills

| Name | Description | Stack | Level | Cost |
|---|---|---|---|---|
| [`ui-components-refactor`](./skills/ui-components-plugin/) | Extract a reusable component library and design tokens from existing HTML/CSS | `html-css` `any` | `mid` `senior` | 🟢 free |

### 🔌 MCP Configurations

*Coming in v0.3 — [contribute one](./CONTRIBUTING.md)*

### ⚙️ CLI Tools

*Coming in v0.4 — [contribute one](./CONTRIBUTING.md)*

### 📋 CLAUDE.md Templates

*Coming in v0.2 — [contribute one](./CONTRIBUTING.md)*

---

## Cost legend

Every tool in this marketplace is transparently labelled:

| Badge | Meaning |
|---|---|
| 🟢 `free` | Zero cost. No accounts, no API keys, runs completely offline or on fully free services |
| 🟡 `freemium` | A usable free tier exists, but limits apply — declared in the manifest |
| 🔴 `requires-paid` | At least one dependency requires a paid account to function |
| 🟠 `mixed` | Cost depends on your configuration — details in the manifest |

---

## Install a skill

```bash
# Add the marketplace to Claude Code
/plugin marketplace add Djacomo/MightyPirAIte

# Install a specific skill
/plugin install ui-components-plugin@mighty-piraite

# Then invoke it
/ui-components-refactor
```

---

## Structure

```
MightyPirAIte/
├── VISION.md                        # Why this exists
├── CONTRIBUTING.md                  # How to join the crew
├── README.md                        # You are here
├── LICENSE
│
├── skills/
│   └── {skill-name}/
│       ├── manifest.yml             # Metadata, stack, level, cost
│       └── SKILL.md
│
├── mcp/
│   └── {service-name}/
│       ├── manifest.yml
│       ├── config.json
│       └── README.md
│
├── cli/
│   └── {tool-name}/
│       ├── manifest.yml
│       ├── {tool-name}.sh
│       └── README.md
│
└── templates/
    └── {stack-name}/
        ├── manifest.yml
        └── CLAUDE.md
```

---

## Design language

| Token | Value | Role |
|---|---|---|
| `--color-bg` | `#0A1628` | Deep ocean — background |
| `--color-text` | `#E8EDF5` | Starlight — primary text |
| `--color-primary` | `#F0C040` | Pirate Gold — accent, titles, CTAs |
| `--color-secondary` | `#2A6EA6` | Caribbean Blue — links, borders |
| `--color-fun` | `#C8860A` | Guinness Amber — quotes, notes |
| `--color-warn` | `#E63946` | Sheldon Red — warnings, callouts |

---

## Roadmap

| Milestone | Status | Goal |
|---|---|---|
| `v0.1 — Raise the anchor` | 🔄 In progress | Foundation: structure, standards, contributing guide |
| `v0.2 — First crew` | ⏳ Planned | Core skills and templates across main stacks |
| `v0.3 — Navigation charts` | ⏳ Planned | MCP configurations library |
| `v0.4 — The CLI` | ⏳ Planned | Installer and bootstrap tool for fresh machines |
| `v1.0 — Open waters` | ⏳ Planned | Community launch, full documentation, stable API |

---

## Contributing

Skills are plain Markdown. MCP configs are JSON. CLI tools are shell scripts.
If you can write it, you can ship it here.

Read [CONTRIBUTING.md](./CONTRIBUTING.md) — it tells you exactly what the standard is and how to meet it.
Read [VISION.md](./VISION.md) — it tells you who we are and where we're going.

---

## License

MIT — use it, fork it, ship it. Keep the copyright line.

*© Djacomo — Mighty PirAIte*
