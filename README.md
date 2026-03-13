# claude-code-notify

Get native desktop notifications when [Claude Code](https://docs.anthropic.com/en/docs/claude-code) finishes responding or needs your input.

Never miss when a long-running task completes or when Claude asks a question — hear a sound and see a notification with project context.

## What you get

- **Response complete** — Sound + notification when Claude finishes (via `Stop` hook)
- **Input needed** — Different sound + notification when Claude needs permission or asks a question (via `Notification` hook)
- **Project context** — Shows the project name and a summary in every notification
- Works with **macOS** (osascript) and **Linux** (notify-send)

Example notifications:

> **Claude Code [my-project]** — _Fixed the authentication bug in login.ts..._

> **Claude Code [my-project]** — _Claude needs permission to run Bash_

## Quick install

```bash
curl -fsSL https://raw.githubusercontent.com/JadenChoi2k/claude-code-notify/main/install.sh | bash
```

This will:
1. Download `notify.sh` and `notify-prompt.sh` to `~/.claude/scripts/`
2. Add `Stop` and `Notification` hooks to `~/.claude/settings.json`

## Manual install

1. Copy scripts to `~/.claude/scripts/`:

```bash
mkdir -p ~/.claude/scripts
cp notify.sh notify-prompt.sh ~/.claude/scripts/
chmod +x ~/.claude/scripts/notify.sh ~/.claude/scripts/notify-prompt.sh
```

2. Add hooks to `~/.claude/settings.json`:

```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/scripts/notify.sh"
          }
        ]
      }
    ],
    "Notification": [
      {
        "matcher": "permission_prompt|elicitation_dialog",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/scripts/notify-prompt.sh"
          }
        ]
      }
    ]
  }
}
```

3. Restart Claude Code.

## Uninstall

```bash
curl -fsSL https://raw.githubusercontent.com/JadenChoi2k/claude-code-notify/main/uninstall.sh | bash
```

Or manually:
```bash
rm ~/.claude/scripts/notify.sh ~/.claude/scripts/notify-prompt.sh
# Then remove the "Stop" and "Notification" hooks from ~/.claude/settings.json
```

## How it works

### `notify.sh` — Stop hook

Fires every time Claude finishes responding. Receives a JSON payload on stdin:

| Field | Description |
|---|---|
| `cwd` | Current working directory |
| `last_assistant_message` | Claude's last response text |
| `session_id` | Session identifier |

Shows the project name (from `cwd`) and a truncated summary of the last response.

### `notify-prompt.sh` — Notification hook

Fires when Claude needs user input. Matches `permission_prompt` and `elicitation_dialog` events. Receives:

| Field | Description |
|---|---|
| `cwd` | Current working directory |
| `notification_type` | Type of notification (`permission_prompt`, `elicitation_dialog`) |
| `message` | Description of what Claude needs |

Uses a different sound (Ping) to distinguish from response-complete notifications (Glass).

## Customization

### Change the sounds (macOS)

Edit the scripts in `~/.claude/scripts/` and change the sound files:

```bash
# Available sounds in /System/Library/Sounds/
afplay /System/Library/Sounds/Glass.aiff &   # notify.sh (response complete)
afplay /System/Library/Sounds/Ping.aiff &    # notify-prompt.sh (input needed)
```

### Change the sounds (Linux)

```bash
paplay /usr/share/sounds/freedesktop/stereo/complete.oga &            # notify.sh
paplay /usr/share/sounds/freedesktop/stereo/dialog-information.oga &  # notify-prompt.sh
```

## Requirements

- **macOS**: No extra dependencies (uses built-in `osascript` and `afplay`)
- **Linux**: `notify-send` (usually pre-installed) and optionally `pulseaudio-utils` for sound
- **Python 3**: Used to parse JSON payload (pre-installed on most systems)

## License

MIT
