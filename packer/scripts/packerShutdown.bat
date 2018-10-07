call winrm set winrm/config/service/auth @{Basic="false"}
call winrm set winrm/config/service @{AllowUnencrypted="false"}
netsh advfirewall firewall set rule name="WinRM-HTTP" new action=block
echo "************ just set the winrm to block before doing the custom shutdown command ***************"
C:/windows/system32/sysprep/sysprep.exe /generalize /oobe /unattend:a:/unattend.xml /quiet /shutdown