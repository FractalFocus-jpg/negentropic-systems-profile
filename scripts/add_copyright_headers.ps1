# Add copyright headers to code files
$header = Get-Content "C:\Users\alexl\Desktop\tapestry-codex-starter\COPYRIGHT_HEADER.txt" -Raw

$files = Get-ChildItem -Path "C:\Users\alexl\Desktop\tapestry-codex-starter" -Recurse -Include *.py,*.ps1 | 
    Where-Object { $_.DirectoryName -notlike "*\.venv*" -and $_.DirectoryName -notlike "*\__pycache__*" }

$updated = 0
foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw
    if ($content -notmatch "Copyright.*Alexander Liantonio") {
        $newContent = $header + "`r`n" + $content
        Set-Content -Path $file.FullName -Value $newContent -NoNewline
        Write-Host "Added header to: $($file.Name)" -ForegroundColor Green
        $updated++
    } else {
        Write-Host "Skipped (has header): $($file.Name)" -ForegroundColor Yellow
    }
}

Write-Host "`nUpdated $updated files" -ForegroundColor Cyan
