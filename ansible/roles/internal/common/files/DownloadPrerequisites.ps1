
#param([string] $SharePoint2013Path = $(Read-Host -Prompt "Please enter the directory path to where you wish to save the SharePoint 2013 Prerequisite files.")) 
  param([Parameter(Mandatory=$true,ValueFromPipeline=$true)]$SPPrerequisitesPath)

 
 $SharePoint2016RTMPath = $SPPrerequisitesPath

# Specify download url's for SharePoint Server 2016 RTM prerequisites 
$DownloadUrls = ( 
            "https://download.microsoft.com/download/C/3/A/C3A5200B-D33C-47E9-9D70-2F7C65DAAD94/NDP46-KB3045557-x86-x64-AllOS-ENU.exe", # .NET framework 4.6 
            "http://download.microsoft.com/download/4/B/1/4B1E9B0E-A4F3-4715-B417-31C82302A70A/ENU/x64/sqlncli.msi", # Microsoft SQL Server 2012 SP1 Native Client  
            "http://download.microsoft.com/download/5/7/2/57249A3A-19D6-4901-ACCE-80924ABEB267/ENU/x64/msodbcsql.msi", #Microsoft ODBC Driver 11 for SQL Server  
            "http://download.microsoft.com/download/E/0/0/E0060D8F-2354-4871-9596-DC78538799CC/Synchronization.msi", # Microsoft Sync Framework Runtime v1.0 SP1 (x64)  
            "http://download.microsoft.com//download/0/1/D/01D06854-CA0C-46F1-ADBA-EBF86010DCC6/rtm/MicrosoftIdentityExtensions-64.msi", # MMicrosoft Identity Extensions  
            "http://download.microsoft.com/download/3/C/F/3CF781F5-7D29-4035-9265-C34FF2369FA2/setup_msipc_x64.exe", # Microsoft Information Protection and Control Client  
            "http://download.microsoft.com/download/A/6/7/A678AB47-496B-4907-B3D4-0A2D280A13C0/WindowsServerAppFabricSetup_x64.exe", # Windows Server AppFabric 1.1  
            "http://download.microsoft.com/download/F/1/0/F1093AF6-E797-4CA8-A9F6-FC50024B385C/AppFabric-KB3092423-x64-ENU.exe", # Cumulative Update 7 for Microsoft AppFabric 1.1 for Windows Server  
            "http://download.microsoft.com/download/C/6/9/C690CC33-18F7-405D-B18A-0A8E199E531C/Windows8.1-KB2898850-x64.msu",
            "http://download.microsoft.com/download/1/6/B/16B06F60-3B20-4FF2-B699-5E9B7962F9AE/VSU_4/vcredist_x64.exe", # Visual C++ Redistributable Package for Visual Studio 2015, 
            "http://download.microsoft.com/download/9/3/F/93FCF1E7-E6A4-478B-96E7-D4B285925B00/vc_redist.x64.exe", # Another visual C++ Redistributable Package for Visual Studio 2013/2012, 
            "http://download.microsoft.com/download/1/C/A/1CAA41C7-88B9-42D6-9E11-3C655656DAB1/WcfDataServices.exe" # Microsoft WCF Data Services 5.6  

                )  
 
 
function DownloadThemPrerequisites(){
    Write-Host "" 
    Write-Host "==============================================================================================" 
    Write-Host "      Downloading SharePoint Server 2016 RTM Prerequisites Please wait..."  
    Write-Host "==============================================================================================" 
    
    $ReturnCode = 0  
    
      foreach ($DownLoadUrl in $DownloadUrls)  
      {  
          ## Get the file name based on the portion of the URL after the last slash  
          $FileName = $DownLoadUrl.Split('/')[-1] 
          Write-Host $FileName 
          Try  
          {  
              ## Check if destination file already exists  
              If (!(Test-Path "$SharePoint2016RTMPath\$FileName"))  
              {  
                  ## Begin download  
                  #Start-BitsTransfer -Asynchronous -Credential $mycreds  -Source $DownLoadUrl -Destination $SharePoint2016RTMPath\$fileName -DisplayName "Downloading `'$FileName`' to $SharePoint2016RTMPath" -Priority High -Description "From $DownLoadUrl..." -ErrorVariable err  
                  (New-Object System.Net.WebClient).DownloadFile($DownLoadUrl, "$SharePoint2016RTMPath\$fileName")
                
              }  
              Else  
              {  
                  Write-Host " - File $FileName already exists, skipping..."  
              }  
          }  
          Catch  
          {  
              $ReturnCode = -1  
              Write-Warning " - An error occurred downloading `'$FileName`'"  
              Write-Error $_  
              break  
          }  
      }  
      Write-Host "Done downloading Prerequisites required for SharePoint Server 2016 RTM"  
        
      return $ReturnCode 
    
}
function DownLoadPreRequisites()  
{  
 
    Write-Host "" 
    Write-Host "==============================================================================================" 
    Write-Host "      Downloading SharePoint Server 2016 RTM Prerequisites Please wait..."  
    Write-Host "==============================================================================================" 
      
    $ReturnCode = 0  
  
    foreach ($DownLoadUrl in $DownloadUrls)  
    {  
        ## Get the file name based on the portion of the URL after the last slash  
        $FileName = $DownLoadUrl.Split('/')[-1]  
        Try  
        {  
            ## Check if destination file already exists  
            If (!(Test-Path "$SharePoint2016RTMPath\$FileName"))  
            {  
                ## Begin download  
                Start-BitsTransfer -Asynchronous -Credential $mycreds  -Source $DownLoadUrl -Destination $SharePoint2016RTMPath\$fileName -DisplayName "Downloading `'$FileName`' to $SharePoint2016RTMPath" -Priority High -Description "From $DownLoadUrl..." -ErrorVariable err  
                If ($err) {Throw ""}  
            }  
            Else  
            {  
                Write-Host " - File $FileName already exists, skipping..."  
            }  
        }  
        Catch  
        {  
            $ReturnCode = -1  
            Write-Warning " - An error occurred downloading `'$FileName`'"  
            Write-Error $_  
            break  
        }  
    }  
    Write-Host "Done downloading Prerequisites required for SharePoint Server 2016 RTM"  
      
    return $ReturnCode  
}  
 
 
  
function DownloadPreReqs()  
{  
    Try 
    { 
        # Check if destination path exists  
        If (Test-Path $SharePoint2016RTMPath)  
        {  
           # Remove trailing slash if it is present 
           $script:SharePoint2016RTMPath = $SharePoint2016RTMPath.TrimEnd('\')            
        } 
        Else { 
           Write-Host "`nYour specified download path does not exist. Proceeding to create same." 
           New-Item -ItemType Directory -Path $SharePoint2016RTMPath 
        } 
     
        $returncode = DownloadThemPrerequisites  #DownLoadPreRequisites  
        if($returncode -ne 0) 
        { 
            Write-Host "Unable to download all files." 
        } 
    } 
    Catch 
    { 
        Write-Error "Exception Type: $($_.Exception.GetType().FullName)"  
        Write-Error "Exception Message: $($_.Exception.Message)"          
    }  
    finally 
    { 
        Write-Host "" 
        Write-Host "Script execution is now complete!" 
        Write-Host "" 
    } 
 
 
}  
 
DownloadPreReqs 

