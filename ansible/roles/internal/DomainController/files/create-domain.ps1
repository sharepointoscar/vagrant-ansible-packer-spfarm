$DomainName = "sposcar.local"
$NetBIOSName = "SPOSCAR"
$AutoLoginUser = "Administrator"
$AutoLoginPassword = "Pass@word1!"

if ((gwmi win32_computersystem).partofdomain -eq $false) {

  Write-Host 'Configuring SharePoint Farm Active Directory Domain Controller'
  # Disable password complexity policy
  secedit /export /cfg C:\secpol.cfg
  (gc C:\secpol.cfg).replace("PasswordComplexity = 1", "PasswordComplexity = 0") | Out-File C:\secpol.cfg
  secedit /configure /db C:\Windows\security\local.sdb /cfg C:\secpol.cfg /areas SECURITYPOLICY
  rm -force C:\secpol.cfg -confirm:$false

  # Set administrator password
  $computerName = $env:COMPUTERNAME
  $adminUser = [ADSI] "WinNT://$computerName/Administrator,User"
  $adminUser.SetPassword($AutoLoginPassword)

  $SecurePassword = $AutoLoginPassword | ConvertTo-SecureString -AsPlainText -Force

  # Windows Server 2012 R2 or Windows Server 2016 since it uses the same Windows Feature to
  # provision the domain
  Install-WindowsFeature AD-domain-services -includemanagementtools
  Import-Module ADDSDeployment
  Install-ADDSForest `
    -SafeModeAdministratorPassword $SecurePassword `
    -CreateDnsDelegation:$false `
    -DatabasePath "C:\Windows\NTDS" `
    -DomainMode "Win2012R2" `
    -DomainName $DomainName `
    -DomainNetbiosName $NetBIOSName `
    -ForestMode "Win2012R2" `
    -InstallDns:$true `
    -LogPath "C:\Windows\NTDS" `
    -NoRebootOnCompletion:$true `
    -SysvolPath "C:\Windows\SYSVOL" `
    -Force:$true `
    -Confirm:$false


}
