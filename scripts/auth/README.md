# 🜂 Authentication Scripts

OAuth flows for social media and Google services.

## Setup Steps

1. **Copy environment template**:
   ```powershell
   Copy-Item .env.local.template .env.local
   ```

2. **Create developer accounts and apps**:
   - [TikTok for Developers](https://developers.tiktok.com/)
   - [Facebook for Developers](https://developers.facebook.com/) (for Instagram)
   - [Google Cloud Console](https://console.cloud.google.com/) (for YouTube + Photos)

3. **Fill in .env.local** with your Client IDs and Secrets

4. **Run OAuth flows** (one at a time):
   ```powershell
   .\scripts\auth\run_oauth_tiktok.ps1
   .\scripts\auth\run_oauth_ig_fb.ps1
   .\scripts\auth\run_oauth_youtube.ps1
   .\scripts\auth\run_oauth_google_photos.ps1
   ```

## Security

- Tokens stored in `secrets/` (git-ignored)
- Never commit `.env.local` or `secrets/` directory
- Tokens auto-refresh when needed
- Only masked tokens shown in logs

## Token Files

After OAuth:
- `secrets/tiktok.token`
- `secrets/instagram.token`
- `secrets/youtube.token`
- `secrets/gphotos.token`

Each contains: `access_token`, `refresh_token`, `expires_in`, `created_at`
