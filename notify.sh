#!/bin/bash
#
# Claude Code Stop Hook — Desktop Notification
# https://github.com/JadenChoi2k/claude-code-notify
#
# Sends a native desktop notification with project context
# when Claude Code finishes responding.
#
# Supported: macOS (terminal-notifier / osascript), Linux (notify-send)
#

INPUT=$(cat)

# macOS: skip notification if a terminal app is focused
if [ "$(uname)" = "Darwin" ]; then
  FRONTMOST=$(osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true' 2>/dev/null)
  case "$FRONTMOST" in
    Terminal|iTerm2|ghostty|kitty|Alacritty|WezTerm|Hyper) exit 0 ;;
  esac
fi

# Parse hook payload
eval "$(echo "$INPUT" | python3 -c "
import sys, json, os

d = json.load(sys.stdin)
cwd = d.get('cwd', '')
msg = d.get('last_assistant_message', '')

# Project name from working directory
project = os.path.basename(cwd) if cwd else 'Unknown'

# First line of last response, truncated to 50 chars
first_line = msg.strip().split('\n')[0] if msg else ''
if len(first_line) > 50:
    first_line = first_line[:47] + '...'

# Escape double quotes for shell safety
project = project.replace('\"', '\\\\\"')
first_line = first_line.replace('\"', '\\\\\"')

print(f'PROJECT=\"{project}\"')
print(f'SUMMARY=\"{first_line}\"')
" 2>/dev/null)"

TITLE="Claude Code [$PROJECT]"
BODY="${SUMMARY:-Response complete}"

case "$(uname)" in
  Darwin)
    afplay /System/Library/Sounds/Glass.aiff &
    if command -v terminal-notifier &>/dev/null; then
      terminal-notifier -title "$TITLE" -message "$BODY" -sound "" -group "claude-code-stop" -activate "com.apple.Terminal"
    else
      osascript -e "display notification \"$BODY\" with title \"$TITLE\""
    fi
    ;;
  Linux)
    notify-send "$TITLE" "$BODY" 2>/dev/null
    paplay /usr/share/sounds/freedesktop/stereo/complete.oga 2>/dev/null &
    ;;
  *)
    echo "Unsupported OS: $(uname)" >&2
    exit 1
    ;;
esac
