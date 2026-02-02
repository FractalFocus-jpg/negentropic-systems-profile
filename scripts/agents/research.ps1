# Research Daemon - LT OS
$date = Get-Date -Format 'yyyy-MM-dd'
$inbox = "C:\Users\alexl\the living tapestry\_inbox\research"
New-Item -ItemType Directory -Path $inbox -Force | Out-Null

$topics = @("PNDR physics", "coherence theory", "phase-locking dynamics")
$content = @"
# Research Digest $date

**Topics**: $(($topics -join ', '))

"@

foreach ($topic in $topics) {
    $content += "`n## $topic`n`nResearch summary pending (requires web search integration)`n"
}

$content | Out-File "$inbox\$date.md" -Encoding UTF8
Write-Host "✅ Research note: $inbox\$date.md"
