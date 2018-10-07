<powershell>
Write-Host "Disabling WinRM over HTTP..."
Disable-NetFirewallRule -Name "WINRM-HTTP-In-TCP"
Disable-NetFirewallRule -Name "WINRM-HTTP-In-TCP-PUBLIC"

Start-Process -FilePath winrm `
    -ArgumentList "delete winrm/config/listener?Address=*+Transport=HTTP" `
    -NoNewWindow -Wait

Write-Host "Configuring WinRM for HTTPS..."
Start-Process -FilePath winrm `
    -ArgumentList "set winrm/config @{MaxTimeoutms=`"1800000`"}" `
    -NoNewWindow -Wait

Start-Process -FilePath winrm `
    -ArgumentList "set winrm/config/winrs @{MaxMemoryPerShellMB=`"1024`"}" `
    -NoNewWindow -Wait

Write-Host "Ensuring non-SSL sessions are denied"
Start-Process -FilePath winrm `
    -ArgumentList "set winrm/config/service @{AllowUnencrypted=`"false`"}" `
    -NoNewWindow -Wait

Write-Host "Enabling basic user authentication"
Start-Process -FilePath winrm `
    -ArgumentList "set winrm/config/service/auth @{Basic=`"true`"}" `
    -NoNewWindow -Wait

Write-Host "Allowing WinRM HTTPS in firewall"
New-NetFirewallRule -Name "WINRM-HTTPS-In-TCP" `
    -DisplayName "Windows Remote Management (HTTPS-In)" `
    -Description "Inbound rule for Windows Remote Management via WS-Management. [TCP 5986]" `
    -Group "Windows Remote Management" `
    -Program "System" `
    -Protocol TCP `
    -LocalPort "5986" `
    -Action Allow `
    -Profile Domain,Private

New-NetFirewallRule -Name "WINRM-HTTPS-In-TCP-PUBLIC" `
    -DisplayName "Windows Remote Management (HTTPS-In)" `
    -Description "Inbound rule for Windows Remote Management via WS-Management. [TCP 5986]" `
    -Group "Windows Remote Management" `
    -Program "System" `
    -Protocol TCP `
    -LocalPort "5986" `
    -Action Allow `
    -Profile Public

Write-Host "Finding the Remote Desktop Certificate"
$SourceStoreScope = 'LocalMachine'
$SourceStorename = 'Remote Desktop'
$SourceStore = New-Object  -TypeName System.Security.Cryptography.X509Certificates.X509Store  -ArgumentList $SourceStorename, $SourceStoreScope
$SourceStore.Open([System.Security.Cryptography.X509Certificates.OpenFlags]::ReadOnly)
$cert = $SourceStore.Certificates | Where-Object  -FilterScript {
$_.subject -like '*'
}

Write-Host "Binding RDP Certificate to WinRM HTTPS Listener"
$DestStoreScope = 'LocalMachine'
$DestStoreName = 'My'
$DestStore = New-Object  -TypeName System.Security.Cryptography.X509Certificates.X509Store  -ArgumentList $DestStoreName, $DestStoreScope
$DestStore.Open([System.Security.Cryptography.X509Certificates.OpenFlags]::ReadWrite)
$DestStore.Add($cert)

$SourceStore.Close()
$DestStore.Close()
winrm create winrm/config/listener?Address=*+Transport=HTTPS  `@`{Hostname=`"($certId)`"`;CertificateThumbprint=`"($cert.Thumbprint)`"`}

Write-Host "Restarting WinRM Service..."
Stop-Service winrm
Set-Service winrm -StartupType "Automatic"
Start-Service winrm

Write-Host "Enabling remote execution of PowerShell scripts"
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope LocalMachine

</powershell>
