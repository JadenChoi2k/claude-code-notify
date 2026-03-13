#!/bin/bash
#
# One-line installer for claude-code-notify
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/JadenChoi2k/claude-code-notify/main/install.sh | bash
#

set -e

SCRIPT_DIR="$HOME/.claude/scripts"
SETTINGS_FILE="$HOME/.claude/settings.json"
BASE_URL="https://raw.githubusercontent.com/JadenChoi2k/claude-code-notify/main"

echo "Installing claude-code-notify..."

# Create scripts directory
mkdir -p "$SCRIPT_DIR"

# Download scripts
curl -fsSL "$BASE_URL/notify.sh" -o "$SCRIPT_DIR/notify.sh"
curl -fsSL "$BASE_URL/notify-prompt.sh" -o "$SCRIPT_DIR/notify-prompt.sh"
chmod +x "$SCRIPT_DIR/notify.sh" "$SCRIPT_DIR/notify-prompt.sh"

echo "✓ Scripts installed to $SCRIPT_DIR/"

# Check for terminal-notifier
if command -v terminal-notifier &>/dev/null; then
  echo "✓ terminal-notifier detected"
else
  echo "⚠ terminal-notifier not found — falling back to osascript"
  echo "  For clickable notifications, run: brew install terminal-notifier"
fi

# Add hooks to settings.json
if [ ! -f "$SETTINGS_FILE" ]; then
  echo '{}' > "$SETTINGS_FILE"
fi

python3 -c "
import json

with open('$SETTINGS_FILE') as f:
    settings = json.load(f)

settings.setdefault('hooks', {})

if 'Stop' not in settings['hooks']:
    settings['hooks']['Stop'] = [
        {
            'hooks': [
                {
                    'type': 'command',
                    'command': '$SCRIPT_DIR/notify.sh'
                }
            ]
        }
    ]
    print('✓ Stop hook added')
else:
    print('⚠ Stop hook already exists — skipping')

if 'Notification' not in settings['hooks']:
    settings['hooks']['Notification'] = [
        {
            'matcher': 'permission_prompt|elicitation_dialog',
            'hooks': [
                {
                    'type': 'command',
                    'command': '$SCRIPT_DIR/notify-prompt.sh'
                }
            ]
        }
    ]
    print('✓ Notification hook added')
else:
    print('⚠ Notification hook already exists — skipping')

with open('$SETTINGS_FILE', 'w') as f:
    json.dump(settings, f, indent=2, ensure_ascii=False)
"

echo ""
echo "Done! You'll now get desktop notifications when Claude Code:"
echo "  • Finishes responding (Glass sound)"
echo "  • Needs your input (Ping sound)"
echo ""
echo "Restart Claude Code for changes to take effect."
