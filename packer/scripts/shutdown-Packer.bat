echo "Disabling WinRM in Firewall (it will be re-enabled during first boot after sysprep (SetupComplete.cmd will be used, it's created with postSetup.ps1))..."
netsh advfirewall firewall set rule group="Windows Remote Management" new enable=No

echo "Executing sysprep..."
c:\windows\system32\sysprep\sysprep.exe /oobe /generalize /shutdown /quiet /unattend:A:/unattend.xml
