# 🜂 Social Post Renderer & Validator
# Validates queued posts and prepares for publishing
# DEFAULT MODE: Review only (no actual posting)

Param(
    [string]$PostPath,
    [switch]$Validate,
    [string]$VaultPath = "C:\Users\alexl\the living tapestry"
)

$ErrorActionPreference = "Stop"

function Test-PostFormat {
    param($Content)
    
    $errors = @()
    
    # Check for frontmatter
    if ($Content -notmatch '(?ms)^---\s*\n.*?\n---') {
        $errors += "Missing YAML frontmatter"
    }
    
    # Extract frontmatter
    if ($Content -match '(?ms)^---\s*\n(.*?)\n---') {
        $fm = $matches[1]
        
        # Required fields
        if ($fm -notmatch 'title:') { $errors += "Missing 'title' field" }
        if ($fm -notmatch 'platforms:') { $errors += "Missing 'platforms' field" }
        if ($fm -notmatch 'status:') { $errors += "Missing 'status' field" }
    }
    
    # Check for caption
    if ($Content -notmatch '(?ms)\*\*Caption\*\*') {
        $errors += "Missing **Caption** section"
    }
    
    return $errors
}

function Get-PostMetrics {
    param($Content)
    
    # Extract caption
    if ($Content -match '(?ms)\*\*Caption\*\*\s*\n(.*?)(\n\*\*|$)') {
        $caption = $matches[1].Trim()
        $charCount = $caption.Length
        $hashtagCount = ([regex]::Matches($caption, '#\w+')).Count
        
        return @{
            char_count = $charCount
            hashtag_count = $hashtagCount
            tiktok_ok = $charCount -le 2200
            instagram_ok = $charCount -le 2200
            twitter_ok = $charCount -le 280
        }
    }
    
    return @{}
}

if (-not $PostPath) {
    Write-Host "Usage: .\render_post.ps1 -PostPath <path> [-Validate]" -ForegroundColor Yellow
    exit 1
}

if (-not (Test-Path $PostPath)) {
    Write-Error "Post file not found: $PostPath"
    exit 1
}

$content = Get-Content $PostPath -Raw -Encoding UTF8
Write-Host "🜂 Rendering Post: $(Split-Path $PostPath -Leaf)" -ForegroundColor Cyan
Write-Host ""

# Validate
$errors = Test-PostFormat -Content $content
if ($errors.Count -gt 0) {
    Write-Host "❌ Validation FAILED:" -ForegroundColor Red
    $errors | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
    exit 1
}

Write-Host "✅ Format Valid" -ForegroundColor Green

# Get metrics
$metrics = Get-PostMetrics -Content $content
if ($metrics.Keys.Count -gt 0) {
    Write-Host ""
    Write-Host "📊 Post Metrics:" -ForegroundColor Cyan
    Write-Host "  Characters: $($metrics.char_count)" -ForegroundColor Gray
    Write-Host "  Hashtags: $($metrics.hashtag_count)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Platform Compatibility:" -ForegroundColor Cyan
    Write-Host "  TikTok: $(if ($metrics.tiktok_ok) {'✅'} else {'❌ Too long'})" -ForegroundColor Gray
    Write-Host "  Instagram: $(if ($metrics.instagram_ok) {'✅'} else {'❌ Too long'})" -ForegroundColor Gray
    Write-Host "  Twitter: $(if ($metrics.twitter_ok) {'✅'} else {'⚠️ Truncate to 280 chars'})" -ForegroundColor Gray
}

Write-Host ""
Write-Host "✅ Post ready for review" -ForegroundColor Green
Write-Host "To publish: Run platform-specific script (post_tiktok.ps1, post_instagram.ps1, etc.)" -ForegroundColor Yellow
Write-Host "Auto-posting is DISABLED by default for safety" -ForegroundColor Yellow
