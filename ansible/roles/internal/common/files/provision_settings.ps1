Write-Host "Disabling UAC"
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLUA"  -Type DWORD -Value 0
Write-host -ForegroundColor Green "UAC disabled..."

Write-Host -ForegroundColor Yellow "Enabling remote execution of PowerShell scripts"
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force
