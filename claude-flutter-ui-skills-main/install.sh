#!/usr/bin/env bash
# flutter-ui Claude Code Skill Installer
# DevCenter — https://devcenter.dev

set -e

SKILL_NAME="flutter-ui"
SKILLS_DIR="$HOME/.claude/skills"
TARGET="$SKILLS_DIR/$SKILL_NAME"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE="$SCRIPT_DIR/$SKILL_NAME"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  flutter-ui — Claude Code Skill Installer"
echo "  DevCenter · https://devcenter.dev"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check source exists
if [ ! -f "$SOURCE/SKILL.md" ]; then
  echo "❌  Error: flutter-ui/SKILL.md not found."
  echo "   Run this script from the repo root:"
  echo "   bash install.sh"
  exit 1
fi

# Create skills dir if needed
if [ ! -d "$SKILLS_DIR" ]; then
  echo "📁  Creating $SKILLS_DIR"
  mkdir -p "$SKILLS_DIR"
fi

# Handle existing install
if [ -d "$TARGET" ]; then
  echo "⚠️   Existing install found at $TARGET"
  read -r -p "   Overwrite? (y/N): " confirm
  if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "   Cancelled."
    exit 0
  fi
  rm -rf "$TARGET"
fi

# Install
echo "📦  Installing $SKILL_NAME to $TARGET"
cp -r "$SOURCE" "$TARGET"

# Verify
if [ -f "$TARGET/SKILL.md" ]; then
  echo ""
  echo "✅  Installed successfully!"
  echo ""
  echo "   Files installed:"
  find "$TARGET" -type f | sort | sed "s|$SKILLS_DIR/||" | sed 's/^/   /'
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "  How to use:"
  echo "  1. Open Claude Code in your Flutter project"
  echo "  2. Type: /flutter-ui"
  echo "  3. Claude will read the skill and fill the"
  echo "     mandatory checkpoint before any UI work"
  echo ""
  echo "  Run the audit script anytime:"
  echo "  python ~/.claude/skills/flutter-ui/scripts/flutter_ui_audit.py ."
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
else
  echo "❌  Installation failed — SKILL.md not found at target."
  exit 1
fi
