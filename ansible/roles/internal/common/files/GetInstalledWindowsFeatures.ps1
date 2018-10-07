Import-module servermanager; 
Get-WindowsFeature | where-object {$_.Installed -eq $True} | format-list DisplayName,Name
