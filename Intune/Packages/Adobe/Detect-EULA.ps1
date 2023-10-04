#Requires -Version 5.1.19041.3031
function Detection-AdobeEULA {
    param ()

    <# 
        .SYNOPSIS
        Checks if the Adobe Acrobat Reader EULA is accepted . 
        If conditions are met, the script exits with a success code (0), otherwise it exits with a remediation required code (1).
        
        .DESCRIPTION
        This PowerShell function checks the following conditions:
        
            1. Verifies if the Adobe Acrobat Reader End-User License Agreement (EULA) is accepted by examining the Windows Registry.
        
        If conditions are met, it indicates that the Adobe Reader is properly configured for automatic updates. 
        If any condition is not met, it suggests that remediation may be required.
        
        The function logs its activities in a hidden log folder within the user's profile directory.
        
        .NOTES
        Author: Koos Janse
        Date: 08/09/2023
        Website: https://www.koosjanse.com
        
        .LINK
        Online version: https://www.koosjanse.com/
        #>


    # Create Log folder in user profile and hide it
    $logfolder = "$env:Public\WorkplacePowershellLogs"
    $logfile = "Adobe-Detection-EULA.log"

    if (!(Test-Path -Path $logfolder)) {
        New-Item -ItemType Directory -Path $logfolder
        Get-Item $logfolder -Force | ForEach-Object { $_.Attributes = $_.Attributes -bor "Hidden" }
    }

    Start-Transcript -Path "$logfolder\$logfile" -Append

    # Define the registry key path and expected value
    $RegistryPath = "HKCU:\SOFTWARE\Adobe\Acrobat Reader\DC\AdobeViewer"
    $RegistryName = "EULA"

    # Initialize variables to track results
    $registryResult = $null
    $endresultEULA = $null

    # Check if the registry path exists
    if (Test-Path -Path $RegistryPath) {
        Write-Host "Registry path exists."
        $endresultEULA = $false

        # If the path exists, check if the registry key exists
        if ((Get-Item -Path $RegistryPath).property -eq "EULA") {
            write-host("EULA key Exists")
            if ((Get-ItemProperty -Path $RegistryPath).$RegistryName -eq "1") {
                $registryValue = (Get-ItemProperty -Path $RegistryPath).$RegistryName
                $registryResult = "Registry Value: $registryValue"
                $endresultEULA = $true
            } else {
                $registryResult = "Registry Key is not set to accept"
                $endresultEULA = $false
            }
        } else {
            # The registry path does not exist
            Write-Host "Registry path $RegistryPath does not exist."
            $endresultEULA = $false
        }
    }

    # Compare the outcomes for exit and remediation
    if ($endresultEULA -eq $true) {
        # Both conditions are met
        Write-Output "Adobe Reader EULA is accepted"
        # Ensure that the transcript is stopped before exiting
        Stop-Transcript
        exit 0  # Success
    } else {
        # At least one condition is not met
        Write-Output "Adobe Reader EULA or Task Schedule Principal is not as expected."
        Write-Output "$registryResult"
        # Ensure that the transcript is stopped before exiting
        Stop-Transcript
        exit 1  # Remediation required
    }
}

Detection-AdobeEULA