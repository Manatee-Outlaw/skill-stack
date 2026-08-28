# Build upload-ready zips for the UNIVERSAL tier.
#
# Destination: claude.ai -> Customize -> Skills -> + -> Upload skill
#
# TWO TRAPS THIS SCRIPT EXISTS TO AVOID:
#
#  1. SKILL.md must sit at the ROOT of the zip. Nesting it in a folder makes the
#     upload fail, sometimes silently.
#
#  2. Zip entry paths must use FORWARD slashes. PowerShell's Compress-Archive writes
#     Windows backslashes ("references\lucide.txt"), which violates the ZIP spec and
#     claude.ai rejects with "Zip file contains path with invalid characters". Only
#     skills with subfolders are affected, so this hides until one exists.
#     Hence the manual ZipArchive writer below instead of Compress-Archive.
#
# Run:
#   powershell -ExecutionPolicy Bypass -File F:\Projects\skill-stack\scripts\build-zips.ps1

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

$repo = Split-Path -Parent $PSScriptRoot
$dist = Join-Path $repo 'dist'

Write-Host ""
Write-Host "Repo: $repo"

if (Test-Path $dist) { Remove-Item $dist -Recurse -Force }
New-Item -ItemType Directory -Path $dist | Out-Null

# --- find universal-tier skills (frontmatter only, never a prose mention) ---
$all = Get-ChildItem -Path (Join-Path $repo 'plugins') -Filter 'SKILL.md' -Recurse -File
$universal = @($all | Where-Object {
    (Get-Content $_.FullName -Raw) -match '(?m)^\s+tier:\s*universal\s*$'
})

Write-Host "Found $($all.Count) skills total, $($universal.Count) tagged universal."
Write-Host ""

if ($universal.Count -eq 0) {
    Write-Host "Nothing to build. Check 'metadata: tier: universal' in frontmatter." -ForegroundColor Yellow
    exit 1
}

# --- build, writing entry paths with forward slashes -----------------------
$built = 0
$failed = @()

foreach ($f in $universal) {
    $dir  = $f.Directory
    $name = $dir.Name
    $zip  = Join-Path $dist "$name.zip"
    $files = Get-ChildItem $dir.FullName -Recurse -File

    try {
        $stream  = [System.IO.File]::Create($zip)
        $archive = New-Object System.IO.Compression.ZipArchive($stream, [System.IO.Compression.ZipArchiveMode]::Create)
        try {
            foreach ($file in $files) {
                # relative path, backslashes converted to the ZIP-spec separator
                $rel = $file.FullName.Substring($dir.FullName.Length + 1).Replace('\', '/')
                $entry = $archive.CreateEntry($rel, [System.IO.Compression.CompressionLevel]::Optimal)
                $es = $entry.Open()
                $fs = [System.IO.File]::OpenRead($file.FullName)
                try { $fs.CopyTo($es) } finally { $fs.Dispose(); $es.Dispose() }
            }
        }
        finally { $archive.Dispose(); $stream.Dispose() }

        $built++
        $extra = if ($files.Count -gt 1) { " ($($files.Count) files)" } else { "" }
        Write-Host ("  {0,-30} {1,7:N0} bytes{2}" -f $name, (Get-Item $zip).Length, $extra)
    }
    catch {
        $failed += $name
        Write-Host "  $name  FAILED: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# --- verify BOTH traps ----------------------------------------------------
Write-Host ""
Write-Host "Verifying zip structure..."

$noRootSkill = @()
$badSeparator = @()

foreach ($z in Get-ChildItem $dist -Filter '*.zip') {
    $a = [System.IO.Compression.ZipFile]::OpenRead($z.FullName)
    try {
        if (-not ($a.Entries | Where-Object { $_.FullName -eq 'SKILL.md' })) {
            $noRootSkill += $z.Name
        }
        # trap 2: any backslash in any entry path is fatal
        if ($a.Entries | Where-Object { $_.FullName -like '*\*' }) {
            $badSeparator += $z.Name
        }
    }
    finally { $a.Dispose() }
}

$problems = $false

if ($noRootSkill.Count -gt 0) {
    $problems = $true
    Write-Host ""
    Write-Host "SKILL.md is not at the zip root in:" -ForegroundColor Red
    $noRootSkill | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
}

if ($badSeparator.Count -gt 0) {
    $problems = $true
    Write-Host ""
    Write-Host "Backslash path separators found (claude.ai will reject these):" -ForegroundColor Red
    $badSeparator | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
}

if ($failed.Count -gt 0) {
    $problems = $true
    Write-Host ""
    Write-Host "Failed to compress:" -ForegroundColor Red
    $failed | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
}

if ($problems) { exit 1 }

Write-Host "  SKILL.md at root:        all $built ok" -ForegroundColor Green
Write-Host "  forward-slash paths:     all $built ok" -ForegroundColor Green
Write-Host ""
Write-Host "Done. $built zips in: $dist"
Write-Host ""
Write-Host "Next: claude.ai -> Customize -> Skills -> + -> Upload skill"
Write-Host "Only re-upload a skill whose content actually changed."
Write-Host ""
