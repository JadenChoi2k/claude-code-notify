#
# Claude Code Notification Hook — Prompt Notification (PowerShell)
# https://github.com/JadenChoi2k/claude-code-notify
#
# Fires when Claude Code needs user input (permission request, question, etc.)
#

$Input = $input | Out-String
$data = $Input | ConvertFrom-Json

$cwd = $data.cwd
$msg = $data.message

# Project name from working directory
if ($cwd) {
    $project = Split-Path $cwd -Leaf
} else {
    $project = "Unknown"
}

# Truncate message
if ($msg -and $msg.Length -gt 60) {
    $msg = $msg.Substring(0, 57) + "..."
}

$title = "Claude Code [$project]"
$body = if ($msg) { $msg } else { "Waiting for your response" }

# Escape XML special characters
$title = $title -replace '&', '&amp;' -replace '<', '&lt;' -replace '>', '&gt;' -replace '"', '&quot;' -replace "'", '&apos;'
$body = $body -replace '&', '&amp;' -replace '<', '&lt;' -replace '>', '&gt;' -replace '"', '&quot;' -replace "'", '&apos;'

# Windows toast notification
[Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null
[Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom, ContentType = WindowsRuntime] | Out-Null

$xml = "<toast><visual><binding template='ToastGeneric'><text>$title</text><text>$body</text></binding></visual></toast>"
$doc = [Windows.Data.Xml.Dom.XmlDocument]::new()
$doc.LoadXml($xml)
[Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier("Claude Code").Show(
    [Windows.UI.Notifications.ToastNotification]::new($doc)
)

# Play notification sound
[System.Media.SystemSounds]::Asterisk.Play()
