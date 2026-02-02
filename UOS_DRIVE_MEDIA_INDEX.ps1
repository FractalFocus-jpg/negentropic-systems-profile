<#
UOS_DRIVE_MEDIA_INDEX.ps1
Metadata-first index for large/binary media to avoid disk blowup.
Scans Drive root and writes a compact index into the vault.

Writes:
- OS/index/DRIVE_MEDIA_INDEX.csv
- OS/index/DRIVE_MEDIA_INDEX.md (summary)

No copies, no deletions.
#>

param(
  [string]$DriveRoot = 'C:\Users\alexl\My Drive',
  [string]$VaultRoot = 'C:\Users\alexl\the living tapestry',
  [int]$MaxRows = 50000
)

$ErrorActionPreference = 'Stop'

$indexDir = Join-Path $VaultRoot 'OS\index'
New-Item -ItemType Directory -Force -Path $indexDir | Out-Null

$csvPath = Join-Path $indexDir 'DRIVE_MEDIA_INDEX.csv'
$mdPath  = Join-Path $indexDir 'DRIVE_MEDIA_INDEX.md'

$now = Get-Date
$iso = $now.ToString('yyyy-MM-ddTHH:mm:ss.ffffzzz')

# file classes
$mediaExt = @('.jpg','.jpeg','.png','.gif','.webp','.heic','.mp4','.mov','.mkv','.avi','.mp3','.wav','.ogg','.m4a','.flac')

$items = Get-ChildItem -LiteralPath $DriveRoot -Recurse -File -ErrorAction SilentlyContinue |
  Where-Object { $mediaExt -contains $_.Extension.ToLowerInvariant() } |
  Sort-Object LastWriteTimeUtc -Descending |
  Select-Object -First $MaxRows

# Write CSV
"path,size,modifiedUtc,createdUtc,ext" | Out-File -LiteralPath $csvPath -Encoding UTF8
foreach($f in $items){
  $p = $f.FullName.Replace('"','""')
  $line = '"{0}",{1},{2},{3},{4}' -f $p,$f.Length,$f.LastWriteTimeUtc.ToString('o'),$f.CreationTimeUtc.ToString('o'),$f.Extension
  Add-Content -LiteralPath $csvPath -Encoding UTF8 -Value $line
}

# Summary MD
$md = New-Object System.Collections.Generic.List[string]
$md.Add('---')
$md.Add('type: drive_media_index')
$md.Add('generated: ' + $iso)
$md.Add('source: ' + $DriveRoot)
$md.Add('---')
$md.Add('')
$md.Add('# Drive Media Index (metadata-first)')
$md.Add('')
$md.Add('- Rows: ' + ($items | Measure-Object).Count)
$md.Add('- CSV: ' + $csvPath)
$md.Add('')
$md.Add('This index tracks media files without copying them into the vault.')
$md | Out-File -LiteralPath $mdPath -Encoding UTF8
