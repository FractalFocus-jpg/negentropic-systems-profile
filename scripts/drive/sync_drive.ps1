# ⬢ Google Drive Sync — Bi-Directional Integration
# Syncs Obsidian vault ↔ Google Drive with IP protection

param(
    [string]$Direction = "both",  # "both", "to-drive", "from-drive"
    [switch]$EncryptSensitive = $true,
    [switch]$DryRun = $true
)

$ErrorActionPreference = "Stop"

Write-Host "`n☁️  Google Drive Sync — Bi-Directional" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan

$vaultRoot = "C:\Users\alexl\the living tapestry"
$repoRoot = "C:\Users\alexl\Desktop\tapestry-codex-starter"

# Load OAuth tokens
$envFile = Join-Path $repoRoot ".env.local"
if (Test-Path $envFile) {
    Get-Content $envFile | ForEach-Object {
        if ($_ -match '^([A-Z_]+)=(.*)$') {
            $name = $matches[1]
            $value = $matches[2]
            if ($value -and $value -ne "") {
                [Environment]::SetEnvironmentVariable($name, $value, "Process")
            }
        }
    }
}

# Check for Drive credentials
$driveClientId = $env:GDRIVE_CLIENT_ID
$driveRefreshToken = $env:GDRIVE_REFRESH_TOKEN

if (!$driveClientId -or !$driveRefreshToken) {
    Write-Host "❌ Google Drive OAuth not configured" -ForegroundColor Red
    Write-Host "   Run: .\scripts\auth\setup_google_oauth.ps1" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Drive credentials loaded" -ForegroundColor Green

# Sync configuration
$syncPaths = @(
    @{
        Local = Join-Path $vaultRoot "research"
        Drive = "LivingTapestry/Research"
        Encrypt = $true
        Description = "Research papers & findings"
    },
    @{
        Local = Join-Path $vaultRoot "projects"
        Drive = "LivingTapestry/Projects"
        Encrypt = $true
        Description = "Project documentation"
    },
    @{
        Local = Join-Path $vaultRoot "finance\ledgers"
        Drive = "LivingTapestry/Finance"
        Encrypt = $true
        Description = "Financial records"
    },
    @{
        Local = Join-Path $vaultRoot "tapestry\queues\published"
        Drive = "LivingTapestry/Published"
        Encrypt = $false
        Description = "Published content (public)"
    },
    @{
        Local = Join-Path $vaultRoot "OS\logs"
        Drive = "LivingTapestry/Backups/Logs"
        Encrypt = $false
        Description = "System logs"
    }
)

# IP-protected file types
$ipProtectedExtensions = @(".md", ".tex", ".py", ".js", ".json", ".yaml", ".csv")

function Test-IPProtected {
    param([string]$FilePath)
    
    $ext = [System.IO.Path]::GetExtension($FilePath).ToLower()
    
    if ($ipProtectedExtensions -contains $ext) {
        $content = Get-Content $FilePath -Raw -ErrorAction SilentlyContinue
        
        # Check for IP markers
        $ipMarkers = @(
            "PROPRIETARY",
            "COPYRIGHT",
            "PATENT",
            "CONFIDENTIAL",
            "β·D",  # Stability equation
            "PLV",  # Phase locking value
            "PNDR"  # Perfect non-destructive re-entry
        )
        
        foreach ($marker in $ipMarkers) {
            if ($content -match $marker) {
                return $true
            }
        }
    }
    
    return $false
}

function Sync-ToGoogleDrive {
    param([hashtable]$SyncConfig)
    
    Write-Host "`n📤 Syncing TO Drive: $($SyncConfig.Description)" -ForegroundColor Yellow
    Write-Host "   Local: $($SyncConfig.Local)" -ForegroundColor Gray
    Write-Host "   Drive: $($SyncConfig.Drive)" -ForegroundColor Gray
    
    if (!(Test-Path $SyncConfig.Local)) {
        Write-Host "   ⚠️  Local path not found, skipping" -ForegroundColor Yellow
        return
    }
    
    $files = Get-ChildItem -Path $SyncConfig.Local -File -Recurse
    $syncCount = 0
    $encryptCount = 0
    $ipProtectCount = 0
    
    foreach ($file in $files) {
        $relativePath = $file.FullName.Substring($SyncConfig.Local.Length + 1)
        
        # Check IP protection
        $isIPProtected = Test-IPProtected -FilePath $file.FullName
        
        if ($isIPProtected) {
            $ipProtectCount++
            Write-Host "   🔒 IP-Protected: $relativePath" -ForegroundColor Magenta
        }
        
        # Check if encryption needed
        $needsEncryption = $SyncConfig.Encrypt -or $isIPProtected
        
        if ($needsEncryption -and $EncryptSensitive) {
            $encryptCount++
            if (!$DryRun) {
                # TODO: Implement actual encryption
                Write-Host "   🔐 Would encrypt: $relativePath" -ForegroundColor Yellow
            } else {
                Write-Host "   🔐 Dry-run: Would encrypt $relativePath" -ForegroundColor DarkYellow
            }
        }
        
        if ($DryRun) {
            Write-Host "   🔍 Would sync: $relativePath" -ForegroundColor DarkGray
        } else {
            # TODO: Implement actual Drive API upload
            Write-Host "   ⚠️  Drive API upload not yet implemented" -ForegroundColor Yellow
            Write-Host "   💡 Use Google Drive Desktop or rclone for now" -ForegroundColor Gray
        }
        
        $syncCount++
    }
    
    Write-Host "`n   📊 Summary:" -ForegroundColor Cyan
    Write-Host "      Files: $syncCount" -ForegroundColor Gray
    Write-Host "      Encrypted: $encryptCount" -ForegroundColor Gray
    Write-Host "      IP-Protected: $ipProtectCount" -ForegroundColor Magenta
}

function Sync-FromGoogleDrive {
    param([hashtable]$SyncConfig)
    
    Write-Host "`n📥 Syncing FROM Drive: $($SyncConfig.Description)" -ForegroundColor Yellow
    Write-Host "   Drive: $($SyncConfig.Drive)" -ForegroundColor Gray
    Write-Host "   Local: $($SyncConfig.Local)" -ForegroundColor Gray
    
    if ($DryRun) {
        Write-Host "   🔍 Dry-run: Would download from Drive" -ForegroundColor DarkYellow
    } else {
        Write-Host "   ⚠️  Drive API download not yet implemented" -ForegroundColor Yellow
        Write-Host "   💡 Use Google Drive Desktop or rclone for now" -ForegroundColor Gray
    }
}

# Execute sync
Write-Host "`n🔄 Sync Direction: $Direction" -ForegroundColor Cyan
Write-Host "🔐 Encryption: $(if ($EncryptSensitive) { 'ENABLED' } else { 'DISABLED' })" -ForegroundColor Yellow
Write-Host "🧪 Mode: $(if ($DryRun) { 'DRY RUN' } else { 'LIVE' })" -ForegroundColor $(if ($DryRun) { "Yellow" } else { "Green" })

foreach ($syncPath in $syncPaths) {
    if ($Direction -eq "both" -or $Direction -eq "to-drive") {
        Sync-ToGoogleDrive -SyncConfig $syncPath
    }
    
    if ($Direction -eq "both" -or $Direction -eq "from-drive") {
        Sync-FromGoogleDrive -SyncConfig $syncPath
    }
}

# Log sync operation
$logFile = Join-Path $vaultRoot "OS\logs\$(Get-Date -Format 'yyyy-MM-dd').md"
$logEntry = @"

## [DRIVE SYNC] — $(Get-Date -Format 'HH:mm:ss')

**Direction**: $Direction  
**Encryption**: $(if ($EncryptSensitive) { 'Enabled' } else { 'Disabled' })  
**Mode**: $(if ($DryRun) { 'Dry Run' } else { 'Live' })  
**Paths**: $($syncPaths.Count)

**Status**: ✅ Scan complete (API implementation pending)

**Note**: Current implementation scans for IP-protected content.  
Full Drive API integration requires additional development.

**Temporary Solution**: Use Google Drive Desktop app for bi-directional sync:
- Install: https://www.google.com/drive/download/
- Sync folder: $vaultRoot
- Drive folder: LivingTapestry/

"@

Add-Content -Path $logFile -Value $logEntry -Encoding UTF8

Write-Host "`n✅ Drive sync scan complete!" -ForegroundColor Green
Write-Host "`n⚠️  NOTE: Full Drive API implementation pending" -ForegroundColor Yellow
Write-Host "   Current: IP detection + encryption planning" -ForegroundColor Gray
Write-Host "   Temporary: Use Google Drive Desktop app" -ForegroundColor Gray
Write-Host "   Future: Native API integration with encryption" -ForegroundColor Gray

Write-Host "`n📄 Log: $logFile" -ForegroundColor Cyan
