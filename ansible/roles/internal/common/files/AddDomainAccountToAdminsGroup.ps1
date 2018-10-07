param([Parameter(Mandatory=$true,ValueFromPipeline=$true)][string]$domain_username, 
[Parameter(Mandatory=$true,ValueFromPipeline=$true)][string]$domain_username_password)

Function Get-AdministratorsGroup
{
    If(!$builtinAdminGroup)
    {
        $builtinAdminGroup = (Get-WmiObject -Class Win32_Group -computername $env:COMPUTERNAME -Filter "SID='S-1-5-32-544' AND LocalAccount='True'" -errorAction "Stop").Name
    }
    Return $builtinAdminGroup
}

# The username is in the format of DOMAIN\username
$username = $domain_username
$password = $domain_username_password
$password = ConvertTo-SecureString "$password" -AsPlaintext -Force
$alreadyAdmin = $false
# The following was suggested by Matthias Einig (http://www.codeplex.com/site/users/view/matein78)
# And inspired by http://toddcarter.net/post/2010/05/03/give-your-application-pool-accounts-a-profile/ & http://blog.brainlitter.com/archive/2010/06/08/how-to-revolve-event-id-1511-windows-cannot-find-the-local-profile-on-windows-server-2008.aspx
Try
{
    $credAccount = New-Object System.Management.Automation.PsCredential $username,$password
    $managedAccountDomain,$managedAccountUser = $username -Split "\\"
    Write-Host -ForegroundColor White "  - Account `"$managedAccountDomain\$managedAccountUser`:"
    Write-Host -ForegroundColor White "   - Creating local profile for $username..."
    # Add managed account to local admins (very) temporarily so it can log in and create its profile
    If (!($localAdmins -contains $managedAccountUser))
    {
        $builtinAdminGroup = Get-AdministratorsGroup
        Write-Host -ForegroundColor White "   - Adding to local Admins..." -NoNewline
        ([ADSI]"WinNT://$env:COMPUTERNAME/$builtinAdminGroup,group").Add("WinNT://$managedAccountDomain/$managedAccountUser")
        Write-Host -ForegroundColor Green "OK done."
    }
    Else
    {
        $alreadyAdmin = $true
    }
    # Spawn a command window using the managed account's credentials, create the profile, and exit immediately
    #Start-Process -WorkingDirectory "$env:SYSTEMROOT\System32\" -FilePath "cmd.exe" -ArgumentList "/C" -LoadUserProfile -NoNewWindow -Credential $credAccount
}
Catch
{
    $_
    Write-Host -ForegroundColor White "."
    Write-Warning "Could not create local user profile for $username"
    break
}

