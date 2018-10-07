#
# install.ps1
#
<#
.SYNOPSIS

    Extract the bundle into Ec2Launch file path.
 
.DESCRIPTION
    
.EXAMPLE

    ./install

#>

$sourcePath = Join-Path $PSScriptRoot -ChildPath "EC2-Windows-Launch.zip"
$destPath = Join-Path $env:programData -ChildPath "Amazon\EC2-Windows\Launch"
$moduleFilePath = Join-Path $destPath -ChildPath "Module\Ec2Launch.psd1"

# Check if source package exists in current location
if(-not (Test-Path $sourcePath)) 
{
    Write-Host ("{0} is not found.. exit!" -f $sourcePath)
    Exit 1
}

# Check if Ec2Launch is already installed
if (Test-Path $destPath)
{
    Remove-Item -Path $destPath -Recurse -Force -Confirm:$false
}

$unpacked = $false;
if ($PSVersionTable.PSVersion.Major -ge 5) 
{
    try 
    {
        # Nano doesn't support Expand-Archive yet, but plans to add it in future release.
        # Attempt to execute Expand-Archive to unzip the source package first.
        Expand-Archive $sourcePath -DestinationPath $destPath -Force

        # Set this TRUE to indicate the unpack is done
        $unpacked = $true;

        Write-Host ("Successfully extract files to {0}" -f $destPath)
    } 
    catch 
    {
        Write-Host "Failed to extract files by Expand-Archive cmdlet.."
    }
}

# If unpack failed with Expand-Archive cmdlet, try it with [System.IO.Compression.ZipFile]::ExtractToDirectory
if (-not $unpacked) 
{
    Write-Host "Attempting it again with [System.IO.Compression.ZipFile]::ExtractToDirectory"

    try 
    {
        # Load [System.IO.Compression.FileSystem]
        Add-Type -AssemblyName System.IO.Compression.FileSystem
    } 
    catch 
    {
        # If failed, try to load [System.IO.Compression.ZipFile]
        Add-Type -AssemblyName System.IO.Compression.ZipFile
    }

    try 
    {
        # Try to unpack the package by [System.IO.Compression.ZipFile]::ExtractToDirectory and move them to destination
        [System.IO.Compression.ZipFile]::ExtractToDirectory("$sourcePath", "$destPath")
        Write-Host ("Successfully extract files to {0}" -f $destPath)
    } 
    catch 
    {
        Write-Host "Failed to extract the files.. exit!"
        Exit 1
    }
}
