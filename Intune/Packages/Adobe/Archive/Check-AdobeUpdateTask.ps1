#Requires -Version 5.1.19041.3031

function Check-AdobeTaskScheduler
{
    param ()

    <#
        .NOTES
        Author: Koos Janse
        Date: 08/09/2023
        website: https://www.koosjanse.com
        
        .SYNOPSIS
        Checks scheduled task if user is  system in order for adobe to perform regular updates and no more need for packages. Run as System. If set to user exit 0

        .LINK
        Online version: https://www.koosjanse.com/ 
    #>

    #Create Log folder in userprofile and hide it
    $logfolder = "$env:Public\WorkplacePowershellLogs"
    $logfile = "Update-Adobe-Detection.log"

    if(!(Test-Path -path $logfolder)){
        New-Item -ItemType Directory -Path $logfolder
        Get-Item $logfolder -Force | foreach { $_.Attributes = $_.Attributes -bor "Hidden" }
    }

    Start-Transcript -Path "$logfolder\$logfile" -Append

    # Define the registry key path and expected value
$RegistryPath = "HKCU:\SOFTWARE\Adobe\Acrobat Reader\DC\AdobeViewer"
$RegistryName = "EULA"
$ExpectedValue = 1

# Check if the registry key exists
if (Test-Path -Path $RegistryPath) {
    # Get the current value
    $ActualValue = (Get-ItemProperty -Path $RegistryPath).$RegistryName

    # Compare the current value with the expected value
    if ($ActualValue -eq $ExpectedValue) {
        # Registry key and value are as expected
        Write-Output "Adobe Reader EULA is accepted (Value: $ActualValue)"
        exit 0  # Success
    } else {
        # Registry key exists but has the wrong value
        Write-Output "Adobe Reader EULA is not accepted (Value: $ActualValue)"
        exit 1  # Remediation required
    }
} else {
    # Registry key does not exist
    Write-Output "Adobe Reader EULA is not accepted (Key does not exist)"
    exit 1  # Remediation required
}



    $principal = Get-ScheduledTask -TaskName "Adobe Acrobat Update Task" | Select-Object -ExpandProperty Principal

    if(!($principal.userid -eq "SYSTEM")){
        Write-host("Task Schedule Principal is NOT system:")
        $principal
        exit 1
        Stop-Transcript
    }

    Write-host("Task Schedule Principal is System:")
    $principal
    Stop-Transcript
    exit 0
}

Check-AdobeTaskScheduler