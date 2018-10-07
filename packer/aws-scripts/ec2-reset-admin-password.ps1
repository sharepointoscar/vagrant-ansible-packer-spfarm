$launchConfig = Get-Content -Path C:\ProgramData\Amazon\EC2-Windows\Launch\Config\LaunchConfig.json | ConvertFrom-Json
$launchConfig.adminPasswordType = 'Specify'
$launchConfig.adminPassword = 'Pass@word1!'
$launchConfig

Set-Content -Value ($launchConfig | ConvertTo-Json) -Path C:\ProgramData\Amazon\EC2-Windows\Launch\Config\LaunchConfig.json
