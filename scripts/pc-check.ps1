# PC check: list background jobs Claude started on this PC that are still running after -MinAgeHours.
# REPORTS ONLY. It never stops anything: it prints the stop command for Eric to paste, if he wants to.
#
# Why (2026-10-21): four waiting loops a Claude session started on 16 Oct were still running five days later, each
# logging in to the dev box every 20-60 s (about 10,000 logins a day). Nothing on the PC listed them, so nobody knew.
#
# How it finds them: every shell Claude Code starts carries its "shell-snapshots" marker on its command line, so
# that marker (not a name pattern) is what is matched. One job = one top shell and everything under it. The
# check's own shell is skipped. Run by sync.bat step 6 (the daily "Sync Claude Skill Stack" task); writes
# scripts\pc-check.txt and, when it finds something, raises a Windows notification.
#
#   powershell -NoProfile -ExecutionPolicy Bypass -File scripts\pc-check.ps1 [-MinAgeHours 6] [-NoToast]
param([double]$MinAgeHours = 6, [switch]$NoToast, [string]$Report = (Join-Path $PSScriptRoot 'pc-check.txt'))

$now = Get-Date
$all = @(Get-CimInstance Win32_Process)
$byId = @{}; $kids = @{}
foreach ($p in $all) {
    $byId[[int]$p.ProcessId] = $p
    $pp = [int]$p.ParentProcessId
    if (-not $kids.ContainsKey($pp)) { $kids[$pp] = New-Object System.Collections.ArrayList }
    [void]$kids[$pp].Add([int]$p.ProcessId)
}
$isClaude = { param($p) $p -and $p.CommandLine -and $p.CommandLine -like '*shell-snapshots/snapshot-*' }

# This check's own ancestry (when Claude runs it, it sits inside a Claude shell itself).
$mine = @{}; $id = $PID
while ($id -and $byId.ContainsKey($id) -and -not $mine.ContainsKey($id)) { $mine[$id] = 1; $id = [int]$byId[$id].ParentProcessId }

function Describe([string]$cmd) {
    # The job itself is the text between "eval '" and the wrapper's trailing "' [< /dev/null] && pwd -P".
    $i = $cmd.IndexOf("&& eval '")
    $m = [regex]::Match($cmd, "'\s*(< /dev/null\s*)?&& pwd -P", 'RightToLeft')
    if ($i -ge 0 -and $m.Success -and $m.Index -gt $i) { $cmd = $cmd.Substring($i + 9, $m.Index - $i - 9) }
    $cmd = $cmd.Replace("'\`"'\`"'", "'").Replace('/c/Windows/System32/OpenSSH/ssh.exe', 'ssh').Replace('-o BatchMode=yes ', '')
    $cmd = ($cmd -replace '[^A-Za-z0-9 .,:;/_\-()=+@#\[\]~'']', ' ') -replace '\s+', ' '
    $cmd = $cmd.Trim()
    if ($cmd.Length -gt 90) { $cmd = $cmd.Substring(0, 87) + '...' }
    return $cmd
}

function Age([timespan]$t) {
    if ($t.TotalDays -ge 1) { return '{0} day(s) {1} h' -f [int][Math]::Floor($t.TotalDays), $t.Hours }
    if ($t.TotalHours -ge 1) { return '{0} h {1} min' -f [int][Math]::Floor($t.TotalHours), $t.Minutes }
    return '{0} min' -f [int][Math]::Floor($t.TotalMinutes)
}

$jobs = @()
foreach ($p in $all) {
    if (-not (& $isClaude $p)) { continue }
    if (& $isClaude $byId[[int]$p.ParentProcessId]) { continue }        # not a top shell: part of another job
    if ($mine.ContainsKey([int]$p.ProcessId)) { continue }              # this check's own shell
    $age = $now - $p.CreationDate
    if ($age.TotalHours -lt $MinAgeHours) { continue }
    $tree = New-Object System.Collections.ArrayList; $todo = New-Object System.Collections.Queue
    $todo.Enqueue([int]$p.ProcessId)
    while ($todo.Count) { $x = $todo.Dequeue(); if ($tree -contains $x) { continue }; [void]$tree.Add($x)
        if ($kids.ContainsKey($x)) { foreach ($k in $kids[$x]) { $todo.Enqueue($k) } } }
    $what = Describe $p.CommandLine
    # A loop is usually asleep between logins, so its own text counts as much as a live ssh under it.
    $ssh = (@($tree | Where-Object { $byId[$_].Name -eq 'ssh.exe' }).Count -gt 0) -or ($what -match '(^|[\s(])ssh\s')
    $jobs += [pscustomobject]@{ Age = $age; Ids = $tree; Ssh = $ssh; What = $what }
}

# An ssh whose shell has already ended (its parent is gone) keeps its session on the other computer open.
foreach ($p in $all) {
    if ($p.Name -ne 'ssh.exe' -or $byId.ContainsKey([int]$p.ParentProcessId)) { continue }
    $age = $now - $p.CreationDate
    if ($age.TotalHours -lt $MinAgeHours) { continue }
    $what = 'ssh left behind by a finished job: ' + (Describe ($p.CommandLine -replace '^.*?ssh\.exe"?\s*', 'ssh '))
    if ($what.Length -gt 120) { $what = $what.Substring(0, 117) + '...' }
    $jobs += [pscustomobject]@{ Age = $age; Ids = @([int]$p.ProcessId); Ssh = $true; What = $what }
}

$hours = if ($MinAgeHours -ge 1) { '{0} hours' -f $MinAgeHours } else { '{0} min' -f [Math]::Round($MinAgeHours * 60, 1) }
$lines = @()
if (-not $jobs.Count) {
    $lines += "PC check: no Claude background jobs left running longer than $hours."
} else {
    $lines += "PC check: $($jobs.Count) Claude background job(s) still running after more than $hours (probably forgotten):"
    $n = 0
    foreach ($j in ($jobs | Sort-Object Age -Descending)) {
        $n++
        $lines += "  $n. running $(Age $j.Age)$(if ($j.Ssh) { ', keeps logging in to another computer' }): $($j.What)"
    }
    $ids = ($jobs | ForEach-Object { $_.Ids } | Sort-Object -Unique) -join ','
    $lines += "To stop them, paste this into PowerShell (it stops only these jobs):"
    $lines += "  Stop-Process -Id $ids -Force"
}
$lines | ForEach-Object { Write-Output $_ }
try { $lines | Set-Content -Path $Report -Encoding UTF8 } catch { Write-Output "PC check: could not write $Report" }
if ($jobs.Count -and -not $NoToast) {
    & (Join-Path $PSScriptRoot 'notify.ps1') -Title 'Leftover Claude jobs on this PC' `
        -Message "$($jobs.Count) background job(s) still running. The list and the stop command: F:\Projects\skill-stack\scripts\pc-check.txt" 2>$null
}
exit 0
