$ErrorActionPreference = "SilentlyContinue"

# psexec -accepteula -d -h -i 0 -u sposcar\vagrant -p Pass@word1! C:\SP\AutoSPInstaller\AutoSPInstallerMain.ps1 C:\SP\AutoSPInstaller\AutoSPInstallerInput.xml

#C:\SP\AutoSPInstaller\AutoSPInstallerMain.ps1 C:\SP\AutoSPInstaller\AutoSPInstallerInput.xml

# Start-Process "powershell.exe" "C:\SP\AutoSPInstaller\AutoSPInstallerMain.ps1"

$username = "sposcar\vagrant"
$passwordPlainText = "Pass@word1!"     
$password = ConvertTo-SecureString "$passwordPlainText" -asplaintext -force
$cred = New-Object -TypeName System.Management.Automation.PSCredential -argumentlist $username,$password

$powershellArguments = "C:\SP\AutoSPInstaller\AutoSPInstallerMain.ps1", "C:\SP\AutoSPInstaller\AutoSPInstallerInput.xml"
Start-Process "powershell.exe" -credential $cred  -ArgumentList $powershellArguments