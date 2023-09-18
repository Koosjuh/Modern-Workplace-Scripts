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


    # Create Log folder in user profile and hide it
    $logfolder = "$env:Public\WorkplacePowershellLogs"
    $logfile = "Update-Adobe-Detection.log"

    if (!(Test-Path -Path $logfolder)) {
        New-Item -ItemType Directory -Path $logfolder
        Get-Item $logfolder -Force | ForEach-Object { $_.Attributes = $_.Attributes -bor "Hidden" }
    }

    Start-Transcript -Path "$logfolder\$logfile" -Append

    # Define the registry key path and expected value
    $RegistryPath = "HKCU:\SOFTWARE\Adobe\Acrobat Reader\DC\AdobeViewer"
    $RegistryName = "EULA"
    $ExpectedValue = 1

    # Initialize variables to track results
    $registryResult = $null
    $taskResult = $null

    # Check if the registry key exists and get its value
    if (Test-Path -Path $RegistryPath) {
        $registryValue = (Get-ItemProperty -Path $RegistryPath).$RegistryName
        $registryResult = "Registry Value: $registryValue"
    } else {
        $registryResult = "Registry Key does not exist"
    }

    # Get the task principal
    $principal = Get-ScheduledTask -TaskName "Adobe Acrobat Update Task" | Select-Object -ExpandProperty Principal

    # Check if the task principal is "SYSTEM"
    if ($principal.userid -eq "SYSTEM") {
        $taskResult = "Task Schedule Principal is SYSTEM"
    } else {
        $taskResult = "Task Schedule Principal is NOT SYSTEM"
    }

    # Compare the outcomes for exit and remediation
    if ($registryResult -eq "Registry Value: $ExpectedValue" -and $taskResult -eq "Task Schedule Principal is SYSTEM") {
        # Both conditions are met
        Write-Output "Adobe Reader EULA is accepted and Task Schedule Principal is SYSTEM."
        # Ensure that the transcript is stopped before exiting
        Stop-Transcript
        exit 0  # Success
    } else {
        # At least one condition is not met
        Write-Output "Adobe Reader EULA or Task Schedule Principal is not as expected."
        Write-Output "$registryResult"
        Write-Output "$taskResult"
        # Ensure that the transcript is stopped before exiting
        Stop-Transcript
        exit 1  # Remediation required
    }

}

Check-AdobeTaskScheduler