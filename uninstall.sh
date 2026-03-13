#!/bin/bash
#
# Uninstaller for claude-code-notify
#

set -e

SCRIPT_DIR="$HOME/.claude/scripts"
SETTINGS_FILE="$HOME/.claude/settings.json"

echo "Uninstalling claude-code-notify..."

# Remove script
if [ -f "$SCRIPT_DIR/notify.sh" ]; then
  rm "$SCRIPT_DIR/notify.sh"
  echo "✓ Removed $SCRIPT_DIR/notify.sh"
fi

# Remove Stop hook from settings
if [ -f "$SETTINGS_FILE" ]; then
  python3 -c "
import json

with open('$SETTINGS_FILE') as f:
    settings = json.load(f)

if 'hooks' in settings and 'Stop' in settings['hooks']:
    del settings['hooks']['Stop']
    if not settings['hooks']:
        del settings['hooks']

with open('$SETTINGS_FILE', 'w') as f:
    json.dump(settings, f, indent=2, ensure_ascii=False)
" 2>/dev/null
  echo "✓ Removed Stop hook from $SETTINGS_FILE"
fi

echo ""
echo "Done! Notifications disabled."
