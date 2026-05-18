#!/usr/bin/env bash
# Install MightyPirAIte skills into ~/.claude/skills/
#
# Usage (curl):
#   curl -fsSL https://raw.githubusercontent.com/Djacomo/MightyPirAIte/master/install.sh | bash
#
# Usage (cloned repo):
#   ./install.sh                  # install all skills
#   ./install.sh squad-planning   # install one skill

set -e

REPO_URL="https://github.com/Djacomo/MightyPirAIte"
TMP_DIR=""
SKILLS_DST="$HOME/.claude/skills"

# Resolve skills source — works both from a cloned repo and via curl|bash
if [ -f "$(dirname "$0")/deploy-skills.sh" ]; then
  SKILLS_SRC="$(cd "$(dirname "$0")/skills" && pwd)"
else
  echo "→ Cloning MightyPirAIte..."
  TMP_DIR="$(mktemp -d)"
  git clone --depth 1 "$REPO_URL" "$TMP_DIR" --quiet
  SKILLS_SRC="$TMP_DIR/skills"
fi

cleanup() { [ -n "$TMP_DIR" ] && rm -rf "$TMP_DIR"; }
trap cleanup EXIT

if [ ! -d "$SKILLS_DST" ]; then
  echo "Error: $SKILLS_DST does not exist — is Claude Code installed?" >&2
  exit 1
fi

FILTER="${1:-}"

installed=0
for skill_dir in "$SKILLS_SRC"/*/; do
  name="$(basename "$skill_dir")"
  [ "$name" = ".DS_Store" ] && continue
  if [ -n "$FILTER" ] && [ "$name" != "$FILTER" ]; then continue; fi
  echo "→ $name"
  rm -rf "$SKILLS_DST/$name"
  cp -r "$skill_dir" "$SKILLS_DST/$name"
  installed=$((installed + 1))
done

if [ "$installed" -eq 0 ]; then
  echo "Skill '$FILTER' not found in MightyPirAIte." >&2
  exit 1
fi

echo "Done — $installed skill(s) installed to $SKILLS_DST"
