# Contributing to claude-code-notify

Thanks for your interest in contributing!

## How to contribute

1. **Open an issue first** — describe the bug or feature you'd like to work on.
2. **Fork and branch** — create a feature branch from `main`.
3. **Run ShellCheck** — make sure your shell scripts pass before submitting:
   ```bash
   shellcheck notify.sh notify-prompt.sh install.sh uninstall.sh
   ```
4. **Submit a PR** — reference the issue in your PR description.

## Guidelines

- Keep it simple. The whole point of this project is minimal complexity.
- No new runtime dependencies. Bash + Python 3 only.
- Test on both macOS and Linux if possible.
