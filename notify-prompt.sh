#!/bin/bash
#
# Claude Code Notification Hook — Prompt Notification
# https://github.com/JadenChoi2k/claude-code-notify
#
# Fires when Claude Code needs user input (permission request, question, etc.)
#
# Supported: macOS (terminal-notifier / osascript), Linux (notify-send), WSL (Windows toast)
#

INPUT=$(cat)

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
    if command -v terminal-notifier &>/dev/null; then
      terminal-notifier -title "$TITLE" -message "$BODY" -sound default -group "claude-code-prompt" -activate "com.apple.Terminal"
    else
      osascript -e "display notification \"$BODY\" with title \"$TITLE\" sound name \"default\""
    fi
    ;;
  Linux)
    if grep -qi microsoft /proc/version 2>/dev/null; then
      # WSL → Windows toast notification via powershell.exe
      powershell.exe -NoProfile -Command "
        [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null
        [Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom, ContentType = WindowsRuntime] | Out-Null
        \$xml = \"<toast><visual><binding template='ToastGeneric'><text>$TITLE</text><text>$BODY</text></binding></visual></toast>\"
        \$doc = [Windows.Data.Xml.Dom.XmlDocument]::new(); \$doc.LoadXml(\$xml)
        [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier('Claude Code').Show(
          [Windows.UI.Notifications.ToastNotification]::new(\$doc)
        )
      " 2>/dev/null
      powershell.exe -NoProfile -Command "[System.Media.SystemSounds]::Asterisk.Play()" 2>/dev/null
    else
      notify-send "$TITLE" "$BODY" 2>/dev/null
      paplay /usr/share/sounds/freedesktop/stereo/dialog-information.oga 2>/dev/null &
    fi
    ;;
  *)
    echo "Unsupported OS: $(uname)" >&2
    exit 1
    ;;
esac
