#!/usr/bin/env bash
# Copies handcrafted skills from this repo to ~/.claude/skills/
# Run after editing or adding a skill: ./deploy-skills.sh

set -e

PLUGINS_SRC="$(cd "$(dirname "$0")/plugins" && pwd)"
SKILLS_DST="$HOME/.claude/skills"
COMMANDS_DST="$HOME/.claude/commands"

if [ ! -d "$SKILLS_DST" ]; then
  echo "Error: $SKILLS_DST does not exist" >&2
  exit 1
fi

deployed=0
for plugin_dir in "$PLUGINS_SRC"/*/; do
  name="$(basename "$plugin_dir")"
  [ "$name" = ".DS_Store" ] && continue

  skill_file="$plugin_dir/skills/$name/SKILL.md"
  if [ -f "$skill_file" ]; then
    echo "→ $name"
    mkdir -p "$SKILLS_DST/$name"
    cp "$skill_file" "$SKILLS_DST/$name/SKILL.md"
    deployed=$((deployed + 1))
  fi

  if [ -d "$plugin_dir/commands" ]; then
    mkdir -p "$COMMANDS_DST"
    cp "$plugin_dir/commands/"*.md "$COMMANDS_DST/" 2>/dev/null || true
    echo "  commands → $COMMANDS_DST"
  fi
done

echo "Done — $deployed skill(s) deployed to $SKILLS_DST"
