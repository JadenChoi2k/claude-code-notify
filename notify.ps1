#
# Claude Code Stop Hook — Desktop Notification (PowerShell)
# https://github.com/JadenChoi2k/claude-code-notify
#
# Sends a Windows toast notification with project context
# when Claude Code finishes responding.
#

$Input = $input | Out-String
$data = $Input | ConvertFrom-Json

$cwd = $data.cwd
$msg = $data.last_assistant_message

# Project name from working directory
if ($cwd) {
    $project = Split-Path $cwd -Leaf
} else {
    $project = "Unknown"
}

# First line of last response, truncated to 50 chars
$firstLine = ""
if ($msg) {
    $firstLine = ($msg.Trim() -split "`n")[0]
    if ($firstLine.Length -gt 50) {
        $firstLine = $firstLine.Substring(0, 47) + "..."
    }
}

$title = "Claude Code [$project]"
$body = if ($firstLine) { $firstLine } else { "Response complete" }

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
