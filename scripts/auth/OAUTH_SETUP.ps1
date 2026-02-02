# ⬢ SAPPHIRE vΩ.10 — Complete OAuth Setup
# Orchestrates OAuth for ALL integrations: Google, Social, Workspace, AI Mesh
# Owner: Alexander Liantonio

param(
    [switch]$GoogleOnly = $false,
    [switch]$WorkspaceOnly = $false,
    [switch]$ShowProgress = $true
)

$ErrorActionPreference = "Stop"

$banner = @"

  ⬢ LIVING TAPESTRY OS vΩ.10 ⬢
  Complete OAuth Configuration
  
  Google · Social · Workspace · AI Mesh
  
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

"@

Write-Host $banner -ForegroundColor Cyan

$envFile = "C:\Users\alexl\Desktop\tapestry-codex-starter\.env.local"
$results = @()

# Ensure .env.local exists
if (!(Test-Path $envFile)) {
    Write-Host "📄 Creating .env.local..." -ForegroundColor Yellow
    $template = "C:\Users\alexl\Desktop\tapestry-codex-starter\.env.local.template"
    Copy-Item $template $envFile
}

function Write-Section {
    param([string]$Title, [string]$Description)
    Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host "  $Title" -ForegroundColor Cyan
    Write-Host "  $Description" -ForegroundColor Gray
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
}

function Update-EnvVar {
    param([string]$Key, [string]$Value)
    
    $content = Get-Content $envFile -Raw
    if ($content -match "$Key=.*") {
        $content = $content -replace "$Key=.*", "$Key=$Value"
    } else {
        $content += "`n$Key=$Value"
    }
    Set-Content -Path $envFile -Value $content -NoNewline
    Write-Host "  ✓ $Key" -ForegroundColor Green
}

# ============================================================================
# GOOGLE SERVICES
# ============================================================================
if (!$WorkspaceOnly) {
    Write-Section "🔵 GOOGLE SERVICES" "Gmail, Calendar, Drive, Photos, YouTube"
    
    Write-Host "`n📝 Instructions:" -ForegroundColor Yellow
    Write-Host "1. Go to: https://console.cloud.google.com/apis/credentials"
    Write-Host "2. Create OAuth 2.0 Client ID (Desktop app)"
    Write-Host "3. Enable APIs: Gmail, Calendar, Drive, Photos Library, YouTube"
    Write-Host "4. Download credentials.json"
    Write-Host ""
    
    $proceed = Read-Host "Have you created OAuth credentials? (yes/skip)"
    
    if ($proceed -eq "yes") {
        Write-Host "`n🔑 Enter Google OAuth Credentials:" -ForegroundColor Cyan
        
        $clientId = Read-Host "Client ID"
        $clientSecret = Read-Host "Client Secret" -AsSecureString
        $clientSecretPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
            [Runtime.InteropServices.Marshal]::SecureStringToBSTR($clientSecret)
        )
        
        # Use same credentials for all Google services
        Update-EnvVar "GMAIL_CLIENT_ID" $clientId
        Update-EnvVar "GMAIL_CLIENT_SECRET" $clientSecretPlain
        Update-EnvVar "GCAL_CLIENT_ID" $clientId
        Update-EnvVar "GCAL_CLIENT_SECRET" $clientSecretPlain
        Update-EnvVar "GDRIVE_CLIENT_ID" $clientId
        Update-EnvVar "GDRIVE_CLIENT_SECRET" $clientSecretPlain
        Update-EnvVar "GPHOTOS_CLIENT_ID" $clientId
        Update-EnvVar "GPHOTOS_CLIENT_SECRET" $clientSecretPlain
        Update-EnvVar "YOUTUBE_CLIENT_ID" $clientId
        Update-EnvVar "YOUTUBE_CLIENT_SECRET" $clientSecretPlain
        
        Write-Host "`n✅ Google OAuth configured" -ForegroundColor Green
        $results += @{Service="Google"; Status="✅ Configured"}
    } else {
        Write-Host "⏭️  Skipped Google" -ForegroundColor Yellow
        $results += @{Service="Google"; Status="⏭️  Skipped"}
    }
}

# ============================================================================
# LINEAR
# ============================================================================
if (!$GoogleOnly) {
    Write-Section "🔷 LINEAR" "Issue tracking & project management"
    
    Write-Host "`n📝 Instructions:" -ForegroundColor Yellow
    Write-Host "1. Go to: https://linear.app/settings/api"
    Write-Host "2. Create new API key"
    Write-Host "3. Copy your Team ID from workspace URL"
    Write-Host ""
    
    $proceed = Read-Host "Configure Linear? (yes/skip)"
    
    if ($proceed -eq "yes") {
        Write-Host "`n🔑 Enter Linear Credentials:" -ForegroundColor Cyan
        
        $apiKey = Read-Host "API Key" -AsSecureString
        $apiKeyPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
            [Runtime.InteropServices.Marshal]::SecureStringToBSTR($apiKey)
        )
        $teamId = Read-Host "Team ID"
        
        Update-EnvVar "LINEAR_API_KEY" $apiKeyPlain
        Update-EnvVar "LINEAR_TEAM_ID" $teamId
        
        Write-Host "`n✅ Linear configured" -ForegroundColor Green
        $results += @{Service="Linear"; Status="✅ Configured"}
    } else {
        Write-Host "⏭️  Skipped Linear" -ForegroundColor Yellow
        $results += @{Service="Linear"; Status="⏭️  Skipped"}
    }
}

# ============================================================================
# CONFLUENCE
# ============================================================================
if (!$GoogleOnly) {
    Write-Section "🔶 CONFLUENCE" "Wiki & documentation"
    
    Write-Host "`n📝 Instructions:" -ForegroundColor Yellow
    Write-Host "1. Go to: https://id.atlassian.com/manage-profile/security/api-tokens"
    Write-Host "2. Create new API token"
    Write-Host "3. Note your Confluence base URL (e.g., yoursite.atlassian.net)"
    Write-Host ""
    
    $proceed = Read-Host "Configure Confluence? (yes/skip)"
    
    if ($proceed -eq "yes") {
        Write-Host "`n🔑 Enter Confluence Credentials:" -ForegroundColor Cyan
        
        $baseUrl = Read-Host "Base URL (e.g., yoursite.atlassian.net)"
        $email = Read-Host "Email"
        $apiToken = Read-Host "API Token" -AsSecureString
        $apiTokenPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
            [Runtime.InteropServices.Marshal]::SecureStringToBSTR($apiToken)
        )
        
        Update-EnvVar "CONFLUENCE_BASE_URL" $baseUrl
        Update-EnvVar "CONFLUENCE_EMAIL" $email
        Update-EnvVar "CONFLUENCE_API_TOKEN" $apiTokenPlain
        
        Write-Host "`n✅ Confluence configured" -ForegroundColor Green
        $results += @{Service="Confluence"; Status="✅ Configured"}
    } else {
        Write-Host "⏭️  Skipped Confluence" -ForegroundColor Yellow
        $results += @{Service="Confluence"; Status="⏭️  Skipped"}
    }
}

# ============================================================================
# NOTION
# ============================================================================
if (!$GoogleOnly) {
    Write-Section "⬛ NOTION" "All-in-one workspace"
    
    Write-Host "`n📝 Instructions:" -ForegroundColor Yellow
    Write-Host "1. Go to: https://www.notion.so/my-integrations"
    Write-Host "2. Create new integration"
    Write-Host "3. Share your databases with the integration"
    Write-Host "4. Copy database IDs from URLs"
    Write-Host ""
    
    $proceed = Read-Host "Configure Notion? (yes/skip)"
    
    if ($proceed -eq "yes") {
        Write-Host "`n🔑 Enter Notion Credentials:" -ForegroundColor Cyan
        
        $secret = Read-Host "Integration Secret" -AsSecureString
        $secretPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
            [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secret)
        )
        
        Write-Host "`nDatabase IDs (press Enter to skip any):" -ForegroundColor Gray
        $tasksDb = Read-Host "Tasks Database ID"
        $contentDb = Read-Host "Content Calendar Database ID"
        $researchDb = Read-Host "Research Database ID"
        
        Update-EnvVar "NOTION_INTEGRATION_SECRET" $secretPlain
        if ($tasksDb) { Update-EnvVar "NOTION_TASKS_DB_ID" $tasksDb }
        if ($contentDb) { Update-EnvVar "NOTION_CONTENT_DB_ID" $contentDb }
        if ($researchDb) { Update-EnvVar "NOTION_RESEARCH_DB_ID" $researchDb }
        
        Write-Host "`n✅ Notion configured" -ForegroundColor Green
        $results += @{Service="Notion"; Status="✅ Configured"}
    } else {
        Write-Host "⏭️  Skipped Notion" -ForegroundColor Yellow
        $results += @{Service="Notion"; Status="⏭️  Skipped"}
    }
}

# ============================================================================
# GITHUB
# ============================================================================
if (!$GoogleOnly) {
    Write-Section "🐙 GITHUB" "Version control & collaboration"
    
    Write-Host "`n📝 Instructions:" -ForegroundColor Yellow
    Write-Host "1. Go to: https://github.com/settings/tokens"
    Write-Host "2. Generate new token (classic)"
    Write-Host "3. Select scopes: repo, workflow, read:org"
    Write-Host ""
    
    $proceed = Read-Host "Configure GitHub? (yes/skip)"
    
    if ($proceed -eq "yes") {
        Write-Host "`n🔑 Enter GitHub Credentials:" -ForegroundColor Cyan
        
        $token = Read-Host "Personal Access Token" -AsSecureString
        $tokenPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
            [Runtime.InteropServices.Marshal]::SecureStringToBSTR($token)
        )
        
        Update-EnvVar "GITHUB_TOKEN" $tokenPlain
        Update-EnvVar "GITHUB_USERNAME" "FractalFocus-jpg"
        Update-EnvVar "GITHUB_REPO" "tapestry-codex-starter"
        
        Write-Host "`n✅ GitHub configured" -ForegroundColor Green
        $results += @{Service="GitHub"; Status="✅ Configured"}
    } else {
        Write-Host "⏭️  Skipped GitHub" -ForegroundColor Yellow
        $results += @{Service="GitHub"; Status="⏭️  Skipped"}
    }
}

# ============================================================================
# AI MESH
# ============================================================================
if (!$GoogleOnly) {
    Write-Section "🤖 AI MESH" "Claude, Gemini, Grok, Copilot, DeepMind"
    
    Write-Host "`n📝 Get API Keys from:" -ForegroundColor Yellow
    Write-Host "  • Claude (Anthropic): https://console.anthropic.com/"
    Write-Host "  • Gemini: https://makersuite.google.com/app/apikey"
    Write-Host "  • Grok (xAI): https://x.ai/api (if available)"
    Write-Host "  • Copilot: https://github.com/features/copilot"
    Write-Host "  • DeepMind: (may require special access)"
    Write-Host ""
    
    $proceed = Read-Host "Configure AI Mesh? (yes/skip)"
    
    if ($proceed -eq "yes") {
        Write-Host "`n🔑 Enter AI API Keys (press Enter to skip):" -ForegroundColor Cyan
        
        $claude = Read-Host "Anthropic (Claude)" -AsSecureString
        if ($claude.Length -gt 0) {
            $claudePlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
                [Runtime.InteropServices.Marshal]::SecureStringToBSTR($claude)
            )
            Update-EnvVar "ANTHROPIC_API_KEY" $claudePlain
        }
        
        $gemini = Read-Host "Google AI (Gemini)" -AsSecureString
        if ($gemini.Length -gt 0) {
            $geminiPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
                [Runtime.InteropServices.Marshal]::SecureStringToBSTR($gemini)
            )
            Update-EnvVar "GEMINI_API_KEY" $geminiPlain
        }
        
        $grok = Read-Host "xAI (Grok)" -AsSecureString
        if ($grok.Length -gt 0) {
            $grokPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
                [Runtime.InteropServices.Marshal]::SecureStringToBSTR($grok)
            )
            Update-EnvVar "GROK_API_KEY" $grokPlain
        }
        
        Write-Host "`n✅ AI Mesh configured" -ForegroundColor Green
        $results += @{Service="AI_Mesh"; Status="✅ Configured"}
    } else {
        Write-Host "⏭️  Skipped AI Mesh" -ForegroundColor Yellow
        $results += @{Service="AI_Mesh"; Status="⏭️  Skipped"}
    }
}

# ============================================================================
# SUMMARY
# ============================================================================

Write-Host "`n" -NoNewline
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "  📊 CONFIGURATION SUMMARY" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan

foreach ($result in $results) {
    $status = $result.Status
    $color = if ($status -like "*✅*") { "Green" } 
             elseif ($status -like "*⏭️*") { "Yellow" }
             else { "Red" }
    
    Write-Host "  $($result.Service): " -NoNewline -ForegroundColor Gray
    Write-Host $status -ForegroundColor $color
}

$configured = ($results | Where-Object { $_.Status -like "*✅*" }).Count
$total = $results.Count

Write-Host "`n✅ Configured: $configured/$total services" -ForegroundColor Green
Write-Host "📄 Credentials saved to: .env.local" -ForegroundColor Cyan

Write-Host "`n🚀 Next Steps:" -ForegroundColor Yellow
Write-Host "  1. Run: .\DEPLOY_AGENT_KIT.ps1"
Write-Host "  2. Verify: .\STATUS_CHECK.ps1"
Write-Host "  3. Monitor: http://localhost:5055"

Write-Host "`n⬢ OAuth setup complete!" -ForegroundColor Cyan
