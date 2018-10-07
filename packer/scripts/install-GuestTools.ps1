if (((Get-WmiObject -Class Win32_ComputerSystem).Manufacturer) -like '*innotek*') {
    Write-Host "Installing VirtualBox guest additions..."
    certutil -addstore -f "TrustedPublisher" A:\oracle.cer
    E:\VBoxWindowsAdditions.exe /S
}

elseif (((Get-WmiObject -Class Win32_ComputerSystem).Manufacturer) -like '*Parallels*') {
    Write-Host "Installing Parallels tools..."
    $pl_iso = "C:\Windows\Temp\win.iso"
    Mount-DiskImage -ImagePath $pl_iso
    $exe = ((Get-DiskImage -ImagePath $pl_iso | Get-Volume).Driveletter + ':\PTAgent.exe')
    $parameters = '/install_silent'
    Start-Process $exe $parameters -Wait
    Dismount-DiskImage -ImagePath $pl_iso
    Remove-Item $pl_iso -Force
}

elseif (((Get-WmiObject -Class Win32_ComputerSystem).Manufacturer) -like '*VMware*') {
    Write-Host "Installing VMware tools..."
    $vmware_iso = "C:\Windows\Temp\windows.iso"
    Mount-DiskImage -ImagePath $vmware_iso
    $exe = ((Get-DiskImage -ImagePath $vmware_iso | Get-Volume).Driveletter + ':\setup64.exe')
    $parameters = '/S /v "/qn REBOOT=R ADDLOCAL=ALL REMOVE=Audio,ThinPrint"'
    Start-Process $exe $parameters -Wait
    Dismount-DiskImage -ImagePath $vmware_iso
    Remove-Item $vmware_iso -Force
}

else {
    Write-Host "WARNING: Guest tools have not been found"
}
