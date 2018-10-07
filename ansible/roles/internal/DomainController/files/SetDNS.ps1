Param(
[Parameter(Mandatory=$true)]
[string]$DNS,
[Parameter(Mandatory=$true)]
[string]$Network
)
# Modify the Network Parameter, Modify the last octet
# Only good on Class C
#TODO: Modify with Subnet parameter.
$tmpNet = $Network.split('.')
$tmpNet[-1] = '*'
$Network = $tmpNet -join '.'

#Get the Network card that matches up to the Network Parameter
$nics = Get-WMIObject Win32_NetworkAdapterConfiguration | Where-Object {$_.IpEnabled -eq 'True' -and $_.IPAddress -Like "$Network"}
#Set DNS
$nics.SetDNSServerSearchOrder($DNS)
