Write-Host "Enabling RDP..."
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 0

Write-Host "Setting Firewall rules..."
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
Enable-NetFirewallRule -DisplayGroup "Windows Remote Management"
Enable-NetFirewallRule -DisplayGroup "Remote Event Log Management"
Enable-NetFirewallRule -DisplayGroup "Remote Service Management"
Enable-NetFirewallRule -DisplayGroup "Windows Firewall Remote Management"
Enable-NetFirewallRule -DisplayGroup "Remote Volume Management"
Enable-NetFirewallRule -DisplayGroup "File and Printer Sharing"

Write-Host "Disabling Shutdown Event Tracker..."
New-Item -Path "registry::HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT" -Name Reliability -Force
Set-ItemProperty -Path "registry::HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Reliability" -Name "ShutdownReasonUI" -Value 0

Write-Host "Setting Execution Policy to Bypass..."
Set-ExecutionPolicy -ExecutionPolicy Bypass -Force

Write-Host "Setting file extensions display..."
Set-ItemProperty -Path "registry::HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value 0

Write-Host "Disabling hybernation..."
Set-ItemProperty -Path "registry::HKLM\SYSTEM\CurrentControlSet\Control\Power" -Name "HibernateEnabled" -Value 0

Write-Host "Disabling Screensaver"
Set-ItemProperty "HKCU:\Control Panel\Desktop" -Name ScreenSaveActive -Value 0 -Type DWord
& powercfg -x -monitor-timeout-ac 0
& powercfg -x -monitor-timeout-dc 0

Write-Host "Setting timezone..."
& "$env:windir\system32\tzutil.exe" /s "FLE Standard Time"

Write-Host "Disabling Server Manager opening at logon..."
New-ItemProperty -Path "HKLM:\Software\Microsoft\ServerManager" -Name "DoNotOpenServerManagerAtLogon" -PropertyType "DWORD" -Value "0x1" -Force

Write-Host "Setting Network location to Public..."
Set-NetConnectionProfile -NetworkCategory "Public"

Write-Host "Enabling DiskPerf in Task Manager..."
Invoke-Command {diskperf -Y}

Write-Host "***** Disabling UAC **** "
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLUA"  -Type DWORD -Value 0 -Force

try {
    Get-ItemProperty -Path "registry::HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Server\ServerLevels" | `
    Select-Object -ExpandProperty "Server-Gui-Shell" -ErrorAction Stop | Out-Null

    Write-Host "Disabling IE Enhanced security..."
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}" -Name "IsInstalled" -Value 0
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}" -Name "IsInstalled" -Value 0
} catch {
    Write-Host "Disabling IE Enhanced security is irrelevant for Core installation"
}
