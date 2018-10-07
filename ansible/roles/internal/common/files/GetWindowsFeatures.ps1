Import-module servermanager;
Get-WindowsFeature | format-list DisplayName,Name > c:\AllWindowsFeatures.txt
