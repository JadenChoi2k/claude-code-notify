#
# One-line installer for claude-code-notify (Windows / PowerShell)
#
# Usage:
#   irm https://raw.githubusercontent.com/JadenChoi2k/claude-code-notify/main/install.ps1 | iex
#

$ErrorActionPreference = "Stop"

$ScriptDir = Join-Path $env:USERPROFILE ".claude\scripts"
$SettingsFile = Join-Path $env:USERPROFILE ".claude\settings.json"
$BaseUrl = "https://raw.githubusercontent.com/JadenChoi2k/claude-code-notify/main"

Write-Host "Installing claude-code-notify..."

# Create scripts directory
New-Item -ItemType Directory -Force -Path $ScriptDir | Out-Null

# Download PowerShell scripts
Invoke-WebRequest -Uri "$BaseUrl/notify.ps1" -OutFile (Join-Path $ScriptDir "notify.ps1")
Invoke-WebRequest -Uri "$BaseUrl/notify-prompt.ps1" -OutFile (Join-Path $ScriptDir "notify-prompt.ps1")

Write-Host "[OK] Scripts installed to $ScriptDir\"

# Detect PowerShell executable
if (Get-Command pwsh -ErrorAction SilentlyContinue) {
    $psExe = "pwsh"
} else {
    $psExe = "powershell"
}

$notifyCmd = "$psExe -NoProfile -File `"$ScriptDir\notify.ps1`""
$notifyPromptCmd = "$psExe -NoProfile -File `"$ScriptDir\notify-prompt.ps1`""

# Add hooks to settings.json
if (-not (Test-Path $SettingsFile)) {
    Set-Content -Path $SettingsFile -Value "{}"
}

$settings = Get-Content $SettingsFile -Raw | ConvertFrom-Json

if (-not $settings.hooks) {
    $settings | Add-Member -NotePropertyName "hooks" -NotePropertyValue ([PSCustomObject]@{})
}

$stopAdded = $false
$notifAdded = $false

if (-not $settings.hooks.Stop) {
    $settings.hooks | Add-Member -NotePropertyName "Stop" -NotePropertyValue @(
        [PSCustomObject]@{
            hooks = @(
                [PSCustomObject]@{
                    type = "command"
                    command = $notifyCmd
                }
            )
        }
    )
    $stopAdded = $true
    Write-Host "[OK] Stop hook added"
} else {
    Write-Host "[!] Stop hook already exists - skipping"
}

if (-not $settings.hooks.Notification) {
    $settings.hooks | Add-Member -NotePropertyName "Notification" -NotePropertyValue @(
        [PSCustomObject]@{
            matcher = "permission_prompt|elicitation_dialog"
            hooks = @(
                [PSCustomObject]@{
                    type = "command"
                    command = $notifyPromptCmd
                }
            )
        }
    )
    $notifAdded = $true
    Write-Host "[OK] Notification hook added"
} else {
    Write-Host "[!] Notification hook already exists - skipping"
}

$settings | ConvertTo-Json -Depth 10 | Set-Content $SettingsFile

Write-Host ""
Write-Host "Done! You'll now get Windows toast notifications when Claude Code:"
Write-Host "  - Finishes responding"
Write-Host "  - Needs your input"
Write-Host ""
Write-Host "Restart Claude Code for changes to take effect."
