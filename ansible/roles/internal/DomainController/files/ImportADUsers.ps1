Import-Module ServerManager
Import-Module ActiveDirectory

$Users = Import-Csv -Delimiter ";" -Path "c:\tmp\import_create_ad_sample_users.csv"
foreach ($User in $Users)
{
    $OU = "CN=Users,DC=sposcar,DC=local"
    $Password = $User.password
    $Detailedname = $User.firstname
    $UserFirstname = $User.Firstname
    $UserLastName = $User.LastName
    $FirstLetterFirstname = $UserFirstname.substring(0,1)
    $JobTitle = $User.Title
    $UserPhone = $User.Phone
    #$UserPhoto = $User.PhotoPath
    $City = $User.City
    $UserState = $User.State
    $Country = $User.Country
    $SAM =  $User.name

    New-ADUser -Title $JobTitle -City $City -State $UserState -OfficePhone $UserPhone -Name $Detailedname -SamAccountName $SAM -UserPrincipalName (“{0}@{1}” -f $SAM,"sposcar.local”) -DisplayName $Detailedname -GivenName $User.Firstname -Surname $User.LastName -AccountPassword (ConvertTo-SecureString $Password -AsPlainText -Force) -PasswordNeverExpires $true -Enabled $true -Path $OU

    #Set-ADUser $SAM -Replace @{thumbnailPhoto=([byte[]](Get-Content $UserPhoto -Encoding byte))}
}
