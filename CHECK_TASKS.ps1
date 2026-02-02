Get-ScheduledTask | Where-Object {$_.TaskName -like 'LT_*'} | Select-Object TaskName, State
