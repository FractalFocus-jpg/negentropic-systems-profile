Get-Process | Where-Object {$_.ProcessName -like '*mcp*' -or $_.ProcessName -like '*uv*'} | Select-Object ProcessName, Id, CPU | Format-Table -AutoSize
