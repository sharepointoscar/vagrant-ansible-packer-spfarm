$SetupCompleteScriptDir = "C:\Windows\Setup\Scripts\"
$SetupCompleteScriptValue = "powershell.exe -Command (Enable-NetFirewallRule -DisplayGroup 'Windows Remote Management')"

if ((Test-Path -Path $SetupCompleteScriptDir) -ne 'True') {
    Write-Host "Creating Windows Setup Custom Script folder..."
    New-Item -Path $SetupCompleteScriptDir -ItemType Directory
} else {
    Write-Host "Windows Setup Custom Script folder already exists..."
}

Write-Host "Creating SetupComplete script..."
New-Item -Path $SetupCompleteScriptDir\SetupComplete.cmd -Type File -Value $SetupCompleteScriptValue -Force
