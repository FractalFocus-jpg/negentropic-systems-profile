# ⬢ Weaver — Obsidian Sync Engine
# Bidirectional vault ↔ data streams sync

param(
    [switch]$FullSync = $false,
    [switch]$DryRun = $false
)

Write-Host "`n🕸️ Weaver — Obsidian Sync" -ForegroundColor Cyan

$vaultRoot = "C:\Users\alexl\the living tapestry"
$repoRoot = "C:\Users\alexl\Desktop\tapestry-codex-starter"

# Sync dashboard snapshots → vault
$runsSource = Join-Path $repoRoot "src\tapestry\runs"
$runsTarget = Join-Path $vaultRoot "runs"

if (Test-Path $runsSource) {
    $snapshots = Get-ChildItem -Path $runsSource -Filter "*.md" -File
    foreach ($snapshot in $snapshots) {
        $targetPath = Join-Path $runsTarget $snapshot.Name
        if (!(Test-Path $targetPath) -or $FullSync) {
            if (!$DryRun) {
                Copy-Item $snapshot.FullName $targetPath
                Write-Host "   ✅ Synced: $($snapshot.Name)" -ForegroundColor Green
            }
        }
    }
}

# Update knowledge graph indices
if (!$DryRun) {
    $statusDash = Join-Path $vaultRoot "OS\STATUS_DASHBOARD.md"
    if (Test-Path $statusDash) {
        $content = Get-Content $statusDash -Raw
        $content = $content -replace '\*\*Last Updated\*\*:.*', "**Last Updated**: $(Get-Date -Format 'yyyy-MM-dd HH:mm') UTC"
        $content | Out-File -FilePath $statusDash -Encoding UTF8
    }
}

Write-Host "✅ Sync complete!" -ForegroundColor Green
