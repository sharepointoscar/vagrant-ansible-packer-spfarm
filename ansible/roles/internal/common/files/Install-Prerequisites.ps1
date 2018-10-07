#Directory path where SP 2016 RTM files are kept
param([Parameter(Mandatory=$true,ValueFromPipeline=$true)]$SharePointBitsPath)
        
write-host " $SharePointBitsPath is the path where the SP binaries are located"
write-host "$SharePointBitsPath\PrerequisiteInstaller.exe"

#Directory path where SP 2016 Pre-requisites files are kept
$PreReqsFilesPath = "c:\SP\2016\prerequisiteinstallerfiles"

Start-Process  "$SharePointBitsPath\PrerequisiteInstaller.exe" -ArgumentList "`
                /SQLNCli:`"$PreReqsFilesPath\sqlncli.msi`" /unattended `
                /IDFX11:`"$PreReqsFilesPath\MicrosoftIdentityExtensions-64.msi`" /unattended `
                /Sync:`"$PreReqsFilesPath\Synchronization.msi`" /unattended`
                /AppFabric:`"$PreReqsFilesPath\WindowsServerAppFabricSetup_x64.exe`" /unattended`
                /MSIPCClient:`"$PreReqsFilesPath\setup_msipc_x64.exe`" /unattended`
                /WCFDataServices56:`"$PreReqsFilesPath\WcfDataServices.exe`" /unattended`
                /DotNetFx:`"$PreReqsFilesPath\NDP46-KB3045557-x86-x64-AllOS-ENU.exe`" /unattended`
                /MSVCRT11:`"$PreReqsFilesPath\vcredist_x64.exe`" /unattended`
                /MSVCRT14:`"$PreReqsFilesPath\vc_redist.x64.exe`" /unattended`
                /KB3092423:`"$PreReqsFilesPath\AppFabric-KB3092423-x64-ENU.exe`" /unattended" -NoNewWindow  -Wait    

                write-host "Successfully Installed SP Prerequisites...."