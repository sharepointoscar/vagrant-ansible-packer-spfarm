function Add-JDAzureRMVMToDomain {
<#
.SYNOPSIS
    The function joins Azure RM virtual machines to a domain.
.EXAMPLE
    Get-AzureRmVM -ResourceGroupName 'spfarmstaging' | Select-Object Name,ResourceGroupName | Add-JDAzureRMVMToDomain -DomainName sposcar.local -Verbose

    # select all VMs in Resource Group execept the one that is the Domain Controller
    Get-AzureRmVM -ResourceGroupName "spfarmstaging" | Select-Object name,ResourceGroupName | Where {$_.name -ne "SP2012R2AD"} | Add-JDAzureRMVMToDomain -DomainName sposcar.local -Verbose
.EXAMPLE
    Add-JDAzureRMVMToDomain -DomainName corp.acme.com -VMName AMS-ADFS1 -ResourceGroupName 'ADFS-WestEurope'
.NOTES
    Author   : Johan Dahlbom, johan[at]dahlbom.eu
    Blog     : 365lab.net
    The script are provided “AS IS” with no guarantees, no warranties, and it confer no rights.
#>
 
param(
    [Parameter(Mandatory=$true)]
    [string]$DomainName,
    [Parameter(Mandatory=$false)]
    [System.Management.Automation.PSCredential]$Credentials = (Get-Credential -Message 'Enter the domain join credentials'),
    [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
    [Alias('VMName')]
    [string]$Name,
    [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
    [ValidateScript({Get-AzureRmResourceGroup -Name $_})]
    [string]$ResourceGroupName
)
    begin {
        #Define domain join settings (username/domain/password)
        $Settings = @{
            Name = $DomainName
            User = "packer@sposcar.local"
            Restart = "true"
            Options = 3
        }
        $ProtectedSettings =  @{
                Password = "Pass@word1!"
        }
        Write-Verbose -Message "Domainname is: $DomainName"
    }
    process {
        try {
            $RG = Get-AzureRmResourceGroup -Name $ResourceGroupName
            $JoinDomainHt = @{
                ResourceGroupName = $RG.ResourceGroupName
                ExtensionType = 'JsonADDomainExtension'
                Name = 'joindomain'
                Publisher = 'Microsoft.Compute'
                TypeHandlerVersion = '1.0'
                Settings = $Settings
                VMName = $Name
                ProtectedSettings = $ProtectedSettings
                Location = $RG.Location
            }
            Write-Verbose -Message "Joining $Name to $DomainName"
            Set-AzureRMVMExtension @JoinDomainHt
        } catch {
            Write-Warning $_
        }
    }
    end { }
}
