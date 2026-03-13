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
SCRIPT_URL="https://raw.githubusercontent.com/JadenChoi2k/claude-code-notify/main/notify.sh"

echo "Installing claude-code-notify..."

# Create scripts directory
mkdir -p "$SCRIPT_DIR"

# Download notify script
curl -fsSL "$SCRIPT_URL" -o "$SCRIPT_DIR/notify.sh"
chmod +x "$SCRIPT_DIR/notify.sh"

echo "✓ Script installed to $SCRIPT_DIR/notify.sh"

# Add hook to settings.json
if [ ! -f "$SETTINGS_FILE" ]; then
  echo '{}' > "$SETTINGS_FILE"
fi

# Check if Stop hook already exists
if python3 -c "
import json
with open('$SETTINGS_FILE') as f:
    d = json.load(f)
if 'hooks' in d and 'Stop' in d['hooks']:
    exit(1)
" 2>/dev/null; then
  # Add Stop hook to settings
  python3 -c "
import json

with open('$SETTINGS_FILE') as f:
    settings = json.load(f)

settings.setdefault('hooks', {})
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

with open('$SETTINGS_FILE', 'w') as f:
    json.dump(settings, f, indent=2, ensure_ascii=False)
"
  echo "✓ Stop hook added to $SETTINGS_FILE"
else
  echo "⚠ Stop hook already exists in $SETTINGS_FILE — skipping"
fi

echo ""
echo "Done! You'll now get desktop notifications when Claude Code finishes responding."
echo "Restart Claude Code for changes to take effect."
