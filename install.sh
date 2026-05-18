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
COMMANDS_DST="$HOME/.claude/commands"

# Resolve plugins source — works both from a cloned repo and via curl|bash
if [ -f "$(dirname "$0")/deploy-skills.sh" ]; then
  PLUGINS_SRC="$(cd "$(dirname "$0")/plugins" && pwd)"
else
  echo "→ Cloning MightyPirAIte..."
  TMP_DIR="$(mktemp -d)"
  git clone --depth 1 "$REPO_URL" "$TMP_DIR" --quiet
  PLUGINS_SRC="$TMP_DIR/plugins"
fi

cleanup() { [ -n "$TMP_DIR" ] && rm -rf "$TMP_DIR"; }
trap cleanup EXIT

if [ ! -d "$SKILLS_DST" ]; then
  echo "Error: $SKILLS_DST does not exist — is Claude Code installed?" >&2
  exit 1
fi

FILTER="${1:-}"

installed=0
for plugin_dir in "$PLUGINS_SRC"/*/; do
  name="$(basename "$plugin_dir")"
  [ "$name" = ".DS_Store" ] && continue
  if [ -n "$FILTER" ] && [ "$name" != "$FILTER" ]; then continue; fi

  skill_file="$plugin_dir/skills/$name/SKILL.md"
  if [ -f "$skill_file" ]; then
    echo "→ $name"
    mkdir -p "$SKILLS_DST/$name"
    cp "$skill_file" "$SKILLS_DST/$name/SKILL.md"
    installed=$((installed + 1))
  fi

  if [ -d "$plugin_dir/commands" ]; then
    mkdir -p "$COMMANDS_DST"
    cp "$plugin_dir/commands/"*.md "$COMMANDS_DST/" 2>/dev/null || true
    echo "  commands → $COMMANDS_DST"
  fi
done

if [ "$installed" -eq 0 ]; then
  echo "Skill '$FILTER' not found in MightyPirAIte." >&2
  exit 1
fi

echo "Done — $installed skill(s) installed to $SKILLS_DST"
