Import-Module ServerManager
Import-Module ActiveDirectory

$Users = Import-Csv -Delimiter ";" -Path "c:\tmp\import_create_ad_users.csv"
foreach ($User in $Users)
{
    $OU = "CN=Managed Service Accounts,DC=sposcar,DC=local"
    $Password = $User.password
    $Detailedname = $User.firstname
    $UserFirstname = $User.Firstname
    $FirstLetterFirstname = $UserFirstname.substring(0,1)
    $SAM =  $User.name
    New-ADUser -Name $Detailedname -SamAccountName $SAM -UserPrincipalName (“{0}@{1}” -f $SAM,”sposcar.local”) -DisplayName $Detailedname -GivenName $user.firstname -Surname $user.name -AccountPassword (ConvertTo-SecureString $Password -AsPlainText -Force) -PasswordNeverExpires $true -Enabled $true -Path $OU
    #New-ADServiceAccount -Name $Detailedname -SamAccountName $SAM -UserPrincipalName $SAM -DisplayName $Detailedname -GivenName $user.firstname -Surname $user.name -AccountPassword (ConvertTo-SecureString $Password -AsPlainText -Force) -Enabled $true -Path $OU
    #New-ADServiceAccount -Name $Detailedname -Path $ou -AccountPassword (ConvertTo-SecureString $Password -AsPlainText -Force) -Enabled $true
}
