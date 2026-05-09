# ⚓ Mighty PirAIte

<p align="center">
<svg width="80" height="80" viewBox="0 0 100 100" fill="none" xmlns="http://www.w3.org/2000/svg" aria-label="Mighty PirAIte Logo">
  <circle cx="50" cy="22" r="10" stroke="#F0C040" stroke-width="4" fill="none"/>
  <line x1="50" y1="32" x2="50" y2="78" stroke="#F0C040" stroke-width="4" stroke-linecap="round"/>
  <line x1="26" y1="44" x2="74" y2="44" stroke="#F0C040" stroke-width="4" stroke-linecap="round"/>
  <path d="M50 78 Q30 78 26 62" stroke="#F0C040" stroke-width="4" fill="none" stroke-linecap="round"/>
  <path d="M50 78 Q70 78 74 62" stroke="#F0C040" stroke-width="4" fill="none" stroke-linecap="round"/>
  <circle cx="50" cy="22" r="3" fill="#F0C040"/>
</svg>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/version-1.0.0-F0C040?style=flat-square&labelColor=0A1628" alt="version">
  <img src="https://img.shields.io/badge/license-MIT-2A6EA6?style=flat-square&labelColor=0A1628" alt="license">
  <img src="https://img.shields.io/badge/Claude_Code-skills-F0C040?style=flat-square&labelColor=0A1628" alt="Claude Code">
  <img src="https://img.shields.io/badge/by-Djacomo-E8EDF5?style=flat-square&labelColor=0A1628" alt="by Djacomo">
</p>

<p align="center"><em>"I am Djacomo, Mighty PirAIte!"</em></p>

---

Claude Code skill marketplace for cloud architects and backend engineers who need to ship good UI — without a design degree.

Each skill is a focused prompt workflow invoked via `/skill-name`. No magic, no black boxes. You read the `SKILL.md`, you know exactly what Claude will do.

---

## Install

```sh
# Add the marketplace
/plugin marketplace add Djacomo/MightyPirAIte

# Install a plugin
/plugin install ui-components-plugin@mighty-piraite
```

---

## Skills

### `ui-components-plugin`

Extracts a reusable UI component library and design tokens from existing HTML/CSS, then applies them consistently across the whole project.

**Invoke:**
```sh
/ui-components-refactor
```

**What it does:**

1. Asks scope — single view, a set of views, or the whole project
2. Scans HTML/CSS for recurring patterns (buttons, cards, tables, badges, inputs...)
3. Proposes a design token set (colors, spacing, typography, radius) mapped from existing values
4. Defines a component API — name, props, variants, token dependencies
5. Produces an incremental refactor plan — small, reviewable diffs, no big-bang rewrites
6. Applies changes one batch at a time, preserving all JS hooks and data attributes

**When to use it:**

- Your CSS works but is not structured — copy-pasted values everywhere
- You want visual consistency across views without rewriting everything from scratch
- You are a backend/infra engineer who needs clean, maintainable frontend code

---

## Design

| Token | Value | Role |
|-------|-------|------|
| `--color-bg` | `#0A1628` | Background |
| `--color-text` | `#E8EDF5` | Primary text |
| `--color-primary` | `#F0C040` | Pirate Gold — accent, titles, CTAs |
| `--color-secondary` | `#2A6EA6` | Caribbean Blue — links, borders |
| `--color-fun` | `#C8860A` | Guinness Amber — quotes, notes |
| `--color-warn` | `#E63946` | Sheldon Red — warnings, callouts |

---

## Structure

```
MightyPirAIte/
├── .claude-plugin/
│   └── marketplace.json
├── plugins/
│   └── ui-components-plugin/
│       ├── .claude-plugin/
│       │   └── plugin.json
│       └── skills/
│           └── ui-components-refactor/
│               └── SKILL.md
└── README.md
```

---

## Contributing

Skills are plain Markdown. Fork, write a `SKILL.md`, open a PR.

If your skill follows the same format — scope → analysis → plan → apply — it fits here.

---

## License

MIT — use it, fork it, ship it. Keep the copyright line.
