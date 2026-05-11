# CLAUDE.md — MightyPirAIte

## Context
Read these files before doing anything:
- VISION.md — what this project is and why
- CONTRIBUTING.md — the standard every contribution must meet
- .github/PROJECT_STATUS.md — current milestone, in progress, next up, session log

## Rules
- Every contribution needs manifest.yml — no exceptions
- Never commit .env — use env.template
- PRs always from feature branches, never commit to master
- Commit messages: Conventional Commits (feat:, fix:, chore:, refactor:)
- New stacks added to manifest only when a real contribution uses them
- When adding external tools, link to official repo — never copy their code
- When in doubt on a decision, add it to .github/PROJECT_STATUS.md decisions log

## Quick commands
- Validate contributions: bash cli/validate/validate.sh
- Install pre-commit hook: cp .github/hooks/pre-commit .git/hooks/pre-commit && chmod +x .git/hooks/pre-commit

## Session prompts
**Start:**
Read CLAUDE.md, then .github/PROJECT_STATUS.md and tell me:
1. Current milestone and status (3 lines max)
2. What was in progress
3. The single next action to take
Do not write any code yet.

**End:**
Update .github/PROJECT_STATUS.md — current status, decisions, session log.