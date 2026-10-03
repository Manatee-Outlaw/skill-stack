# Show a Windows notification. Used by sync.bat when check-drift.py finds a problem, because the
# scheduled sync window closes on its own and a warning printed there is never seen.
# Uses the built-in Windows 10 toast API - no module to install.
param([string]$Title = "Skill stack", [string]$Message = "Something needs attention.")
[void][Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime]
[void][Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime]
$esc = { param($s) [Security.SecurityElement]::Escape($s) }
$xml = New-Object Windows.Data.Xml.Dom.XmlDocument
$xml.LoadXml("<toast><visual><binding template='ToastGeneric'><text>$(& $esc $Title)</text><text>$(& $esc $Message)</text></binding></visual></toast>")
# Windows PowerShell's own app id - always registered, so the toast shows without an installer.
$appId = '{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\WindowsPowerShell\v1.0\powershell.exe'
[Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($appId).Show([Windows.UI.Notifications.ToastNotification]::new($xml))
