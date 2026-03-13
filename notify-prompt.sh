#!/bin/bash
#
# Claude Code Notification Hook — Prompt Notification
# https://github.com/JadenChoi2k/claude-code-notify
#
# Fires when Claude Code needs user input (permission request, question, etc.)
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

# Parse notification type and message
eval "$(echo "$INPUT" | python3 -c "
import sys, json, os

d = json.load(sys.stdin)
cwd = d.get('cwd', '')
msg = d.get('message', '')

project = os.path.basename(cwd) if cwd else 'Unknown'

# Truncate message
if len(msg) > 60:
    msg = msg[:57] + '...'

# Escape double quotes for shell safety
project = project.replace('\"', '\\\\\"')
msg = msg.replace('\"', '\\\\\"')

print(f'PROJECT=\"{project}\"')
print(f'MSG=\"{msg}\"')
" 2>/dev/null)"

TITLE="Claude Code [$PROJECT]"
BODY="${MSG:-Waiting for your response}"

case "$(uname)" in
  Darwin)
    afplay /System/Library/Sounds/Ping.aiff &
    if command -v terminal-notifier &>/dev/null; then
      terminal-notifier -title "$TITLE" -message "$BODY" -sound "" -group "claude-code-prompt" -activate "com.apple.Terminal"
    else
      osascript -e "display notification \"$BODY\" with title \"$TITLE\""
    fi
    ;;
  Linux)
    notify-send "$TITLE" "$BODY" 2>/dev/null
    paplay /usr/share/sounds/freedesktop/stereo/dialog-information.oga 2>/dev/null &
    ;;
  *)
    echo "Unsupported OS: $(uname)" >&2
    exit 1
    ;;
esac
