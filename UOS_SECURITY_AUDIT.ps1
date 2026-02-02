<#
UOS_SECURITY_AUDIT.ps1
Non-destructive local security audit.
Writes:
  C:\Users\alexl\the living tapestry\OS\reports\SECURITY_AUDIT_YYYY-MM-DD.md
Also appends a short entry to OS/logs/YYYY-MM-DD.md

No network exposure. No deletions.
#>

param(
  [string]$VaultRoot = 'C:\Users\alexl\the living tapestry'
)

$ErrorActionPreference = 'Stop'

$ts = Get-Date
$day = $ts.ToString('yyyy-MM-dd')
$iso = $ts.ToString('yyyy-MM-ddTHH:mm:ss.ffffzzz')

$reports = Join-Path $VaultRoot 'OS\reports'
$logsDir = Join-Path $VaultRoot 'OS\logs'
New-Item -ItemType Directory -Force -Path $reports | Out-Null
New-Item -ItemType Directory -Force -Path $logsDir | Out-Null

$outPath = Join-Path $reports ("SECURITY_AUDIT_{0}.md" -f $day)
$logPath = Join-Path $logsDir ("{0}.md" -f $day)

function TryRun($scriptblock) {
  try { & $scriptblock } catch { "[error] $($_.Exception.Message)" }
}

$def = TryRun { Get-MpComputerStatus | Select-Object AMServiceEnabled,AntispywareEnabled,AntivirusEnabled,RealTimeProtectionEnabled,IoavProtectionEnabled,BehaviorMonitorEnabled,OnAccessProtectionEnabled,IsTamperProtected,QuickScanAge,FullScanAge,LastQuickScanTime,LastFullScanTime | Format-List | Out-String -Width 2000 }
$fw  = TryRun { (Get-NetFirewallProfile | Select-Object Name,Enabled,DefaultInboundAction,DefaultOutboundAction | Format-Table -AutoSize | Out-String -Width 2000) }
$tcp = TryRun { (Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue | Select-Object -First 60 LocalAddress,LocalPort,OwningProcess | Sort-Object LocalPort | Format-Table -AutoSize | Out-String -Width 2000) }
# process sanity check (avoid complex parsing issues)
$proc = 'ok'

# Startup entries (WMI) - concise
$startup = TryRun { (Get-CimInstance Win32_StartupCommand | Select-Object -First 40 Name,Location | Format-Table -AutoSize | Out-String -Width 2000) }

# Scheduled tasks (only our known names + anything recently modified is heavy; keep narrow)
$tasks = TryRun {
  $names = @('ClawdbotGatewayEnsure','UOSHeartbeatSync','UOSDriveFullSync','UOSObjectiveExtractor','UOSNightlyObjectives','UOSAgentServicesOvernight','UOSAgentServicesEnsure','UOSDriveInboxSync','UOSDriveFullSync','UOSDriveFullSync','UOSNightlyObjectives')
  $rows = foreach($n in ($names | Sort-Object -Unique)){
    $t = schtasks /Query /TN $n /FO LIST /V 2>$null
    if($LASTEXITCODE -eq 0){
      $t | Select-String -Pattern 'TaskName:|Status:|Scheduled Task State:|Last Run Time:|Last Result:|Task To Run:' | ForEach-Object {$_.Line}
      ''
    }
  }
  $rows -join "`r`n"
}

$md = New-Object System.Collections.Generic.List[string]
$md.Add('---')
$md.Add('type: security_audit')
$md.Add('generated: ' + $iso)
$md.Add('scope: local_non_destructive')
$md.Add('---')
$md.Add('')
$md.Add('# Security Audit (local)')
$md.Add('')
$md.Add('## Windows Defender status')
$md.Add('```')
$md.Add($def.TrimEnd())
$md.Add('```')
$md.Add('')
$md.Add('## Firewall profiles')
$md.Add('```')
$md.Add($fw.TrimEnd())
$md.Add('```')
$md.Add('')
$md.Add('## Listening TCP ports (top 60)')
$md.Add('```')
$md.Add($tcp.TrimEnd())
$md.Add('```')
$md.Add('')
$md.Add('## Startup commands (top 40)')
$md.Add('```')
$md.Add($startup.TrimEnd())
$md.Add('```')
$md.Add('')
$md.Add('## Our automation tasks (status excerpt)')
$md.Add('```')
$md.Add($tasks.TrimEnd())
$md.Add('```')
$md.Add('')
$md.Add('## Notes')
$md.Add('- This report is generated locally and does not expose services to the internet.')
$md.Add('- If you want outbound phishing protection, we can add: browser hardening + DNS filtering + email link scanning (still confirm-first).')

$md | Out-File -LiteralPath $outPath -Encoding UTF8

Add-Content -LiteralPath $logPath -Encoding UTF8 -Value ("`r`n`r`n## [SECURITY_AUDIT] - $iso`r`n- Report: $outPath`r`n")
