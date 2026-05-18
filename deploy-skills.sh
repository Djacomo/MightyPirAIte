#!/usr/bin/env bash
# Copies handcrafted skills from this repo to ~/.claude/skills/
# Run after editing or adding a skill: ./deploy-skills.sh

set -e

SKILLS_SRC="$(cd "$(dirname "$0")/skills" && pwd)"
SKILLS_DST="$HOME/.claude/skills"

if [ ! -d "$SKILLS_DST" ]; then
  echo "Error: $SKILLS_DST does not exist" >&2
  exit 1
fi

for skill_dir in "$SKILLS_SRC"/*/; do
  name="$(basename "$skill_dir")"
  echo "→ $name"
  rm -rf "$SKILLS_DST/$name"
  cp -r "$skill_dir" "$SKILLS_DST/$name"
done

echo "Done — $(ls "$SKILLS_SRC" | grep -v '\.DS_Store' | wc -l | tr -d ' ') skills deployed to $SKILLS_DST"
