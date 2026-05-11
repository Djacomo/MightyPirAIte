# 🏴‍☠️ Contributing to MightyPirAIte

> *"Every great ship is built by many hands."*
> Welcome aboard. Here's how to join the crew.

---

## Before you start

Read [VISION.md](./VISION.md) first. Seriously.
It tells you who we are, who we serve, and what quality means here.
If your contribution fits that picture, you're in the right place.

---

## What you can contribute

| Type | Description | Example |
|---|---|---|
| `skill` | Prompt workflow invoked via `/skill-name` | `/flutter-clean-arch` |
| `mcp` | Ready-to-use MCP server configuration | `supabase-mcp` |
| `cli` | Shell script or automation tool | `bootstrap-mac.sh` |
| `template` | `CLAUDE.md` for a specific project type | `flutter-template` |

Not sure which type fits? Open a Discussion before writing anything.

---

## Repository structure

```
MightyPirAIte/
├── VISION.md
├── CONTRIBUTING.md
├── README.md
├── LICENSE
│
├── skills/                          # /skill-name workflows
│   └── {skill-name}/
│       ├── manifest.yml             # Required metadata
│       └── SKILL.md                 # The skill itself
│
├── mcp/                             # MCP configurations
│   └── {service-name}/
│       ├── manifest.yml
│       ├── config.json              # MCP config template
│       └── README.md                # Setup instructions
│
├── cli/                             # Shell tools and scripts
│   └── {tool-name}/
│       ├── manifest.yml
│       ├── {tool-name}.sh           # The script
│       └── README.md
│
└── templates/                       # CLAUDE.md project templates
    └── {stack-name}/
        ├── manifest.yml
        └── CLAUDE.md
```

---

## The manifest — mandatory for every contribution

Every contribution **must** include a `manifest.yml` at its root.
No manifest = PR will not be reviewed.

```yaml
# manifest.yml

name: your-tool-name                 # kebab-case, unique in its category
type: skill                          # skill | mcp | cli | template
version: 1.0.0                       # semver
author: your-github-handle
description: >
  One or two sentences. What it does and when to use it.
  Be specific. "Helps with code" is not a description.

# Target stack — pick all that apply
# Add a new stack only if it doesn't exist yet in the registry
stack:
  - flutter                          # flutter | ios | android | react-native
  - any                              # react | vue | angular | html-css
                                     # node | python | java | kotlin | scala | php
                                     # docker | kubernetes | github-actions | terraform
                                     # supabase | firebase | postgresql | mysql | any

# Target level — pick all that apply
level:
  - mid                              # junior | mid | senior | architect | any

# Environment
claude-code-version: ">=1.0.0"
tested-on:
  - macOS                            # macOS | Linux | Windows

# Cost transparency — mandatory, no exceptions
# Declare the real cost for the user, including all external dependencies
cost:
  level: free                        # free | freemium | requires-paid | mixed

  # Required for freemium, requires-paid, mixed:
  dependencies:
    - name: Supabase
      url: https://supabase.com/pricing
      free-tier: true                # Does a usable free tier exist?
      free-tier-limits: "500MB DB, 2GB bandwidth/month"
      paid-from: "$25/month"         # Lowest paid plan, or omit if free-tier is sufficient

  # Optional but recommended: link to your own pricing page if the tool itself has one
  tool-pricing-url: ~                # null if the tool itself is always free

# Optional
tags:
  - architecture
  - refactor
```

---

## Cost transparency — the rule with no exceptions

**Every user has the right to know what they are getting into before running a single command.**

This is not optional. A missing or inaccurate `cost` block is grounds for immediate PR rejection.

### The four levels

| Level | Meaning | Example |
|---|---|---|
| `free` | Zero cost. No accounts, no API keys, no free tiers with hidden limits. Runs completely offline or on fully free services. | A local shell script with no external calls |
| `freemium` | A free tier exists and is genuinely usable, but limits apply. Declare those limits honestly. | Supabase MCP — free tier covers most hobby projects |
| `requires-paid` | At least one dependency requires a paid account to function at all. No free tier, or free tier is too limited to be useful. | A skill that calls a paid API with no free quota |
| `mixed` | Cost depends on user choices — some configurations are free, others are not. Explain each path. | A CLI that works with both Supabase (freemium) and AWS (requires-paid) |

### Rules for declaring dependencies

- Declare **every** external service, API, or tool the user must sign up for
- Include the **pricing page URL** — do not summarize pricing yourself, it changes
- If a free tier exists, declare its **actual limits** (storage, requests, bandwidth)
- If the free tier is not sufficient for the tool's intended use, use `requires-paid`
- Never write "free" when you mean "has a free tier" — they are not the same thing

### What happens if cost information is wrong

If a merged contribution is found to have inaccurate cost information:
- An Issue is opened immediately
- The contributor has 48 hours to submit a correction PR
- If unresolved, the contribution is pulled until corrected

We do not tolerate surprises on billing. Ever.

---

## Skill format (`SKILL.md`)

A skill is a **focused prompt workflow**. It does one thing. It does it well.

```markdown
---
name: your-skill-name
type: skill
version: 1.0.0
---

## What this skill does

One paragraph. Be precise. What problem does it solve?

## When to use it

- Bullet list of concrete situations
- Not "when you want better code" — "when your feature folder has no separation between UI and business logic"

## When NOT to use it

- Be honest about limitations
- This builds trust

## Invoke

/your-skill-name

## Input

What Claude Code needs before running this skill:
- An open project in the working directory
- Specific files or context required

## What it does — step by step

1. First action
2. Second action
3. ...

Each step must be deterministic and verifiable by the user.

## Output

What the user gets at the end. Be specific:
- Files created or modified
- What to expect in the terminal
- Any follow-up action required

## Example

Show a real before/after or a sample invocation with expected output.
```

---

## MCP configuration format

```markdown
# {service-name} MCP

## What this connects

One paragraph on the service and why you'd connect it to Claude Code.

## Prerequisites

- Account on X service
- API key or OAuth token
- Any CLI tool required

## Install

Step-by-step. Assume the reader is on a fresh machine.

## config.json

Explain every field. Never commit real secrets — use placeholder values.

## What Claude Code can do after connecting

Concrete list of capabilities unlocked.

## Known limitations

Be honest.
```

---

## Step-by-step: how to submit a contribution

### 1. Fork the repo

```bash
git clone https://github.com/YOUR_USERNAME/MightyPirAIte
cd MightyPirAIte
git checkout -b feature/your-tool-name
```

### 2. Create your folder

```bash
# For a skill:
mkdir -p skills/your-skill-name

# For an MCP:
mkdir -p mcp/your-service-name

# For a CLI tool:
mkdir -p cli/your-tool-name

# For a template:
mkdir -p templates/your-stack-name
```

### 3. Write the manifest and content

Follow the formats above exactly.
Run a self-review checklist before committing (see below).

### 4. Test it

- Skills: run the skill on a real project, not a toy example
- MCP: verify the connection on a clean machine or fresh shell
- CLI: test on macOS and at least one other OS if possible
- Templates: open a new project, drop in the CLAUDE.md, run the start-of-session prompt

### 5. Open a Pull Request

Use this PR title format:
```
[skill] your-skill-name — one-line description
[mcp]  your-service-name — one-line description
[cli]  your-tool-name — one-line description
[template] your-stack-name — one-line description
```

Fill in the PR template. It exists for a reason.

---

## Self-review checklist

Before opening a PR, go through this. Every item must be ✅.

```
[ ] manifest.yml is present and valid
[ ] All required manifest fields are filled
[ ] stack and level are declared
[ ] description is specific (not generic)
[ ] I tested this on a real project
[ ] I declared the OS I tested on
[ ] SKILL.md / README.md follows the format
[ ] No hardcoded secrets or personal paths
[ ] Folder name is kebab-case
[ ] PR title follows the format

# Cost transparency — non negotiable
[ ] cost.level is declared (free | freemium | requires-paid | mixed)
[ ] Every external dependency is listed under cost.dependencies
[ ] Every dependency has a pricing URL
[ ] Free tier limits are declared honestly (if applicable)
[ ] I have verified pricing is current as of today
```

---

## What happens after you open a PR

1. **Automated check** — manifest validation (coming in v0.4)
2. **Review** — maintainer reviews within 7 days
3. **Feedback** — one round of requested changes max
4. **Merge or close** — with a clear reason if closed

We do not merge:
- Untested contributions
- Missing or incomplete manifests
- Vague descriptions
- Tools that duplicate existing ones without clear improvement

---

## Reporting issues

Found a bug in an existing skill? Open an Issue with:

- The skill name
- Your OS and Claude Code version
- What you expected vs what happened
- Steps to reproduce

---

## Opening a Discussion

Have an idea but not sure if it fits?
Want to propose a new stack or contribution type?
Open a **Discussion** before writing code.

It saves everyone time — including yours.

---

## Code of conduct

- Be direct. Disagreement is fine, disrespect is not.
- Credit the work of others.
- No stack wars. Every tool in this marketplace serves real developers.
- If you're unsure, ask. Discussions are open.

---

## License

By contributing, you agree that your contribution will be licensed under MIT.

*© Djacomo — Mighty PirAIte*
