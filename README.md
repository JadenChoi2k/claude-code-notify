# claude-code-notify

Get native desktop notifications when [Claude Code](https://docs.anthropic.com/en/docs/claude-code) finishes responding.

Never miss when a long-running task completes — hear a sound and see a notification with the project name and a summary of what Claude said.

## What you get

- **Sound alert** when Claude finishes responding
- **Desktop notification** with project name and response summary
- Works with **macOS** (osascript) and **Linux** (notify-send)

Example notification:

> **Claude Code [my-project]**
>
> Fixed the authentication bug in login.ts...

## Quick install

```bash
curl -fsSL https://raw.githubusercontent.com/JadenChoi2k/claude-code-notify/main/install.sh | bash
```

This will:
1. Download `notify.sh` to `~/.claude/scripts/`
2. Add a `Stop` hook to `~/.claude/settings.json`

## Manual install

1. Copy `notify.sh` to `~/.claude/scripts/`:

```bash
mkdir -p ~/.claude/scripts
cp notify.sh ~/.claude/scripts/notify.sh
chmod +x ~/.claude/scripts/notify.sh
```

2. Add the hook to `~/.claude/settings.json`:

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
rm ~/.claude/scripts/notify.sh
# Then remove the "Stop" hook from ~/.claude/settings.json
```

## How it works

Claude Code fires a [`Stop` hook](https://docs.anthropic.com/en/docs/claude-code/hooks) every time it finishes responding. The hook receives a JSON payload on stdin containing:

| Field | Description |
|---|---|
| `cwd` | Current working directory |
| `last_assistant_message` | Claude's last response text |
| `session_id` | Session identifier |

The script extracts the project name from `cwd` and truncates the last response to show as the notification body.

## Customization

### Change the sound (macOS)

Edit `~/.claude/scripts/notify.sh` and change the sound file:

```bash
# Available sounds in /System/Library/Sounds/
afplay /System/Library/Sounds/Ping.aiff &
```

### Change the sound (Linux)

```bash
paplay /usr/share/sounds/freedesktop/stereo/message.oga &
```

## Requirements

- **macOS**: No extra dependencies (uses built-in `osascript` and `afplay`)
- **Linux**: `notify-send` (usually pre-installed) and optionally `pulseaudio-utils` for sound
- **Python 3**: Used to parse JSON payload (pre-installed on most systems)

## License

MIT
