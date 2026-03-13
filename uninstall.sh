#!/bin/bash
#
# Uninstaller for claude-code-notify
#

set -e

SCRIPT_DIR="$HOME/.claude/scripts"
SETTINGS_FILE="$HOME/.claude/settings.json"

echo "Uninstalling claude-code-notify..."

# Remove scripts
for script in notify.sh notify-prompt.sh; do
  if [ -f "$SCRIPT_DIR/$script" ]; then
    rm "$SCRIPT_DIR/$script"
    echo "✓ Removed $SCRIPT_DIR/$script"
  fi
done

# Remove hooks from settings
if [ -f "$SETTINGS_FILE" ]; then
  python3 -c "
import json

with open('$SETTINGS_FILE') as f:
    settings = json.load(f)

changed = False
for hook in ['Stop', 'Notification']:
    if 'hooks' in settings and hook in settings['hooks']:
        del settings['hooks'][hook]
        print(f'✓ Removed {hook} hook')
        changed = True

if changed:
    if not settings.get('hooks'):
        del settings['hooks']
    with open('$SETTINGS_FILE', 'w') as f:
        json.dump(settings, f, indent=2, ensure_ascii=False)
" 2>/dev/null
fi

echo ""
echo "Done! Notifications disabled."
