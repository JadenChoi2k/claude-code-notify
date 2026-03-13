<h1 align="center">claude-code-notify</h1>
<p align="center"><strong>Claude Code 데스크톱 알림. 스크립트 두 개. 명령어 하나. 끝.</strong></p>
<p align="center">
  <img src="https://img.shields.io/github/license/JadenChoi2k/claude-code-notify?style=flat-square" alt="License">
  <img src="https://img.shields.io/github/stars/JadenChoi2k/claude-code-notify?style=flat-square" alt="Stars">
  <img src="https://img.shields.io/badge/platform-macOS%20%7C%20Linux-lightgrey?style=flat-square" alt="Platform">
  <img src="https://img.shields.io/badge/dependencies-zero-green?style=flat-square" alt="Dependencies">
  <img src="https://img.shields.io/github/actions/workflow/status/JadenChoi2k/claude-code-notify/shellcheck.yml?label=shellcheck&style=flat-square" alt="ShellCheck">
</p>

<p align="center">🌏 <a href="README.md">English</a> | <strong>한국어</strong></p>

<p align="center">
  <img src="assets/demo.png" alt="Demo — 터미널 출력이 데스크톱 알림을 트리거" width="600">
</p>

## 빠른 설치

```bash
# terminal-notifier 설치 (권장, macOS)
brew install terminal-notifier

# 훅 설치 — 이게 끝
curl -fsSL https://raw.githubusercontent.com/JadenChoi2k/claude-code-notify/main/install.sh | bash
```

Claude Code를 재시작하면 끝.

## 뭘 해주나요

- **응답 완료** (`Stop` hook) — 시스템 사운드 + 응답 요약이 담긴 알림
- **입력 필요** (`Notification` hook) — Claude가 권한을 요청할 때 시스템 사운드 + 알림
- **프로젝트 컨텍스트** — 모든 알림에 현재 프로젝트 이름 표시
- **클릭하면 터미널로 이동** — 알림 클릭 시 터미널로 바로 전환 ([terminal-notifier](https://github.com/julienXX/terminal-notifier) 사용)
- **알림 그룹핑** — 같은 카테고리의 이전 알림을 교체해서 스팸 방지
- **자동 폴백** — terminal-notifier가 없으면 `osascript`로 자동 전환
- **macOS**와 **Linux** 지원

알림 예시:

> **Claude Code [my-project]** — _Fixed the authentication bug in login.ts..._

> **Claude Code [my-project]** — _Claude needs permission to run Bash_

## 왜 이걸 써야 하나요?

| | claude-code-notify | claude-notifications-go | CCNotify |
|---|---|---|---|
| 설치 방법 | `curl \| bash` | 바이너리 다운로드 | VS Code 전용 |
| 의존성 | 없음 (bash + python3) | Go 바이너리 (~8 MB) | VS Code 확장 |
| 클릭하면 포커스 | Yes | No | Yes (VS Code) |
| 알림 그룹핑 | Yes | No | N/A |
| 전체 크기 | ~3 KB | ~8 MB | Extension |

## 수동 설치

1. 스크립트를 `~/.claude/scripts/`에 복사:

```bash
mkdir -p ~/.claude/scripts
cp notify.sh notify-prompt.sh ~/.claude/scripts/
chmod +x ~/.claude/scripts/notify.sh ~/.claude/scripts/notify-prompt.sh
```

2. `~/.claude/settings.json`에 훅 추가:

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

3. Claude Code 재시작.

## 제거

```bash
curl -fsSL https://raw.githubusercontent.com/JadenChoi2k/claude-code-notify/main/uninstall.sh | bash
```

수동으로 제거하려면:
```bash
rm ~/.claude/scripts/notify.sh ~/.claude/scripts/notify-prompt.sh
# 그런 다음 ~/.claude/settings.json에서 "Stop"과 "Notification" 훅을 제거
```

## 작동 방식

### `notify.sh` — Stop hook

Claude가 응답을 마칠 때마다 실행됨. stdin으로 JSON 페이로드를 받음:

| 필드 | 설명 |
|---|---|
| `cwd` | 현재 작업 디렉토리 |
| `last_assistant_message` | Claude의 마지막 응답 텍스트 |
| `session_id` | 세션 식별자 |

프로젝트 이름(`cwd` 기반)과 마지막 응답의 요약을 표시.

### `notify-prompt.sh` — Notification hook

Claude가 사용자 입력을 필요로 할 때 실행됨. `permission_prompt`과 `elicitation_dialog` 이벤트를 매칭. 다음을 받음:

| 필드 | 설명 |
|---|---|
| `cwd` | 현재 작업 디렉토리 |
| `notification_type` | 알림 유형 |
| `message` | Claude가 필요로 하는 것에 대한 설명 |

완료 알림과 구분하기 위해 별도의 알림 그룹을 사용.

## 커스터마이징

### 사운드

두 스크립트 모두 `-sound default` (시스템 알림 사운드)를 사용. 변경하려면:

```bash
# 특정 macOS 사운드 사용
terminal-notifier ... -sound Glass

# 사용 가능한 사운드: Basso, Blow, Bottle, Frog, Funk, Glass, Hero, Morse, Ping, Pop, Purr, Sosumi, Submarine, Tink
```

### 터미널 앱 활성화

기본적으로 알림을 클릭하면 Terminal.app이 활성화됨. 다른 터미널을 쓴다면 `-activate` 플래그를 수정:

```bash
# iTerm2
terminal-notifier ... -activate "com.googlecode.iterm2"

# Ghostty
terminal-notifier ... -activate "com.mitchellh.ghostty"

# Kitty
terminal-notifier ... -activate "net.kovidgoyal.kitty"
```

## 알려진 제한사항

- **Notification hook 딜레이**: `Notification` hook은 1~10초 정도 지연될 수 있음. `Stop` hook은 즉시 실행됨.
- **VS Code**: VS Code 확장에서는 Notification hook이 작동하지 않을 수 있음 ([#11156](https://github.com/anthropics/claude-code/issues/11156)). Stop hook은 정상 작동.
- **idle_prompt**: `idle_prompt` 알림은 실행까지 60초의 하드코딩된 타임아웃이 있음.

## 요구사항

- **macOS**: [terminal-notifier](https://github.com/julienXX/terminal-notifier) (권장) 또는 내장 `osascript`
- **Linux**: `notify-send` (보통 기본 설치됨) + 사운드를 위한 `pulseaudio-utils` (선택)
- **Python 3**: JSON 페이로드 파싱에 사용 (대부분의 시스템에 기본 설치됨)

## 로드맵

- [ ] 터미널 앱 자동 감지 (Ghostty, iTerm2, Kitty)
- [ ] 완료 알림에 소요 시간 표시
- [ ] 방해 금지 모드 인식 (macOS)
- [ ] 환경 변수로 사운드 커스터마이징
- [ ] WSL 지원

## 기여하기

가이드라인은 [CONTRIBUTING.md](CONTRIBUTING.md)를 참고하세요.

## 라이선스

[MIT](LICENSE)
