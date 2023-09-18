#Requires -Version 5.1.19041.3031
function Update-AdobeTaskScheduler
{
    param ()

    <#
        .NOTES
        Author: Koos Janse
        Date: 08/09/2023
        website: https://www.koosjanse.com
        
        .SYNOPSIS
        Set scheduled task to system in order for adobe to perform regular updates and no more need for packages. Run as System.

        .LINK
        Online version: https://www.koosjanse.com/ 
    #>

    # Create Log folder in user profile and hide it
    $logfolder = "$env:Public\WorkplacePowershellLogs"
    $logfile = "Update-Adobe-Remediation.log"

    if (!(Test-Path -Path $logfolder)) {
        New-Item -ItemType Directory -Path $logfolder
        Get-Item $logfolder -Force | ForEach-Object { $_.Attributes = $_.Attributes -bor "Hidden" }
    }

    Start-Transcript -Path "$logfolder\$logfile" -Append

    # Define the registry key path and the desired value
    $RegistryPath = "HKCU:\SOFTWARE\Adobe\Acrobat Reader\DC\AdobeViewer"
    $RegistryName = "EULA"
    $DesiredValue = 1

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

    # Check if the registry value is not as desired, and if so, set it
    if ($registryValue -ne $DesiredValue) {
        Set-ItemProperty -Path $RegistryPath -Name $RegistryName -Value $DesiredValue
        $registryResult = "Registry Value set to $DesiredValue"
    }

    # Get the current task principal
    $principal = Get-ScheduledTask -TaskName "Adobe Acrobat Update Task" | Select-Object -ExpandProperty Principal

    # Define the desired SYSTEM principal
    $DesiredPrincipal = New-ScheduledTaskPrincipal -UserId 'NT AUTHORITY\SYSTEM' -RunLevel Highest

    # Check if the task principal is not as desired, and if so, set it
    if ($principal.Userid -ne $DesiredPrincipal.Userid) {
        Set-ScheduledTaskPrincipal -TaskName "Adobe Acrobat Update Task" -Principal $DesiredPrincipal -Verbose
        $taskResult = "Task Schedule Principal set to SYSTEM"
    } else {
        $taskResult = "Task Schedule Principal is already SYSTEM"
    }

    # Compare the outcomes for exit and remediation
    if ($registryValue -eq $DesiredValue -and $principal.Userid -eq $DesiredPrincipal.Userid) {
        # Both conditions are met
        Write-Output "Adobe Reader EULA and Task Schedule Principal are as desired."
        Write-Output "$registryResult"
        Write-Output "$taskResult"
        # Ensure that the transcript is stopped before exiting
        Stop-Transcript
        exit 0  # Success
    } else {
        # At least one condition is not met
        Write-Output "Adobe Reader EULA or Task Schedule Principal is not as desired."
        Write-Output "$registryResult"
        Write-Output "$taskResult"
        # Ensure that the transcript is stopped before exiting
        Stop-Transcript
        exit 1  # Remediation failed
    }
}

Update-AdobeTaskScheduler