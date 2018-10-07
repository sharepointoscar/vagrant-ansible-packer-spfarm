Param([Parameter(Mandatory=$true)][string]$NewComputerName)

Rename-Computer -NewName $NewComputerName
Start-Sleep -Seconds 5
Restart-Computer -Force
