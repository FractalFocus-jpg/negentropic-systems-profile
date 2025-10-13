# ⬢ Hermes Multi-Account Configuration
# Handles multiple Instagram accounts + TikTok + YouTube

# Instagram Accounts Configuration
$instagramAccounts = @(
    @{
        Handle = "@realeyesrealizinglies"
        AppId = $env:IG_APP_ID_REALEYESREALIZING
        AccessToken = $env:IG_ACCESS_TOKEN_REALEYESREALIZING
        PageId = $env:FB_PAGE_ID_REALEYESREALIZING
        Theme = "consciousness, awareness, truth"
    },
    @{
        Handle = "@resonantroot"
        AppId = $env:IG_APP_ID_RESONANTROOT
        AccessToken = $env:IG_ACCESS_TOKEN_RESONANTROOT
        PageId = $env:FB_PAGE_ID_RESONANTROOT
        Theme = "resonance, grounding, nature"
    },
    @{
        Handle = "@newilluminati"
        AppId = $env:IG_APP_ID_NEWILLUMINATI
        AccessToken = $env:IG_ACCESS_TOKEN_RESONANTROOT
        PageId = $env:FB_PAGE_ID_NEWILLUMINATI
        Theme = "illumination, knowledge, awakening"
    }
)

# TikTok Account
$tiktokAccount = @{
    Handle = "@fractalfocus"
    ClientKey = $env:TIKTOK_CLIENT_KEY
    AccessToken = $env:TIKTOK_ACCESS_TOKEN
    Theme = "fractals, coherence, patterns"
}

# YouTube Account
$youtubeAccount = @{
    Handle = "@mrfocusification"
    ClientId = $env:YOUTUBE_CLIENT_ID
    AccessToken = $env:YOUTUBE_ACCESS_TOKEN
    Theme = "focus, coherence, productivity"
}

# Platform-specific post limits
$platformLimits = @{
    Instagram = @{
        CaptionMaxLength = 2200
        HashtagLimit = 30
        PostsPerDay = 25
    }
    TikTok = @{
        CaptionMaxLength = 150
        HashtagLimit = 5
        PostsPerDay = 10
    }
    YouTube = @{
        TitleMaxLength = 100
        DescriptionMaxLength = 5000
        PostsPerDay = 5
    }
}

# Content routing by theme
function Get-BestPlatformForContent {
    param([string]$Theme, [string]$ContentType)
    
    $recommendations = @()
    
    switch ($ContentType) {
        "short-video" {
            $recommendations += "TikTok"
            $recommendations += "Instagram-Reels"
        }
        "image" {
            $recommendations += "Instagram"
        }
        "long-video" {
            $recommendations += "YouTube"
        }
        "text" {
            $recommendations += "Instagram"
            $recommendations += "TikTok" 
        }
    }
    
    # Theme-based Instagram account selection
    if ($Theme -match "consciousness|awareness|truth") {
        $recommendations += "Instagram-@realeyesrealizinglies"
    }
    elseif ($Theme -match "resonance|nature|grounding") {
        $recommendations += "Instagram-@resonantroot"
    }
    elseif ($Theme -match "illumination|knowledge|awakening") {
        $recommendations += "Instagram-@newilluminati"
    }
    
    return $recommendations
}

# Export configuration
Export-ModuleMember -Variable @(
    'instagramAccounts',
    'tiktokAccount',
    'youtubeAccount',
    'platformLimits'
) -Function 'Get-BestPlatformForContent'
