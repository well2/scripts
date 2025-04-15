#!/bin/bash

# Brew Cleaner - find and optionally remove orphaned Homebrew formulae
# Author: (your name or GitHub handle)
# License: MIT

echo "📦 Getting all currently installed formulae..."
ALL=$(brew list)
LEAVES=$(brew leaves)

echo ""
echo "🌿 Formulae installed directly by you (leaves):"
echo "$LEAVES"

echo ""
echo "🧩 All dependencies of those leaves:"
DEPS=$(brew deps --installed --include-optional $LEAVES | sort -u)
echo "$DEPS"

echo ""
echo "🗑️ Potential orphans – not a leaf and not needed by anything else:"
ORPHANS=$(comm -23 <(echo "$ALL" | sort) <(echo -e "$LEAVES\n$DEPS" | sort))
echo "$ORPHANS"

echo ""
echo "💡 Do you want to uninstall these orphaned formulae? (y/n)"
read confirm
if [ "$confirm" == "y" ]; then
  echo "$ORPHANS" | xargs brew uninstall
  echo "✅ Done. You may also run 'brew cleanup' to free disk space."
else
  echo "❌ Skipped. You can uninstall them manually later."
fi
