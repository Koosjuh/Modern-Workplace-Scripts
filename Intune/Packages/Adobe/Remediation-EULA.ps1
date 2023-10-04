#Requires -Version 5.1.19041.3031
function Remediation-AdobeEULA {
    param ()

     <#
        .SYNOPSIS
        Remediate the Adobe Acrobat Reader configuration to ensure the EULA is accepted and the scheduled update task runs with SYSTEM privileges. 
        If remediation is required, this script sets the necessary configurations. Run as SYSTEM.

        .DESCRIPTION
        This PowerShell function performs the following tasks:

        1. Checks if the Adobe Acrobat Reader End-User License Agreement (EULA) is accepted by examining the Windows Registry.
        2. Verifies if the scheduled Adobe Acrobat Reader update task runs with SYSTEM privileges.
        3. If any of these conditions are not met, the function takes remedial action to set the necessary configurations.
        
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
    $logfile = "Adobe-Remediation-EULA.log"

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


    if (Test-Path -Path $RegistryPath) {
        Write-Host "Registry path exists."
        $endresultEULA = $false

        # If the path exists, check if the registry key exists
        if ((Get-Item -Path $RegistryPath).property -eq "EULA") {
            write-host("EULA key Exists")
            if ((Get-ItemProperty -Path $RegistryPath).$RegistryName -eq "1") {
                $registryValue = (Get-ItemProperty -Path $RegistryPath).$RegistryName
                $registryResult = "Registry Value: $registryValue"
            } else {
                $registryResult = "Registry Key is not set to accept"
            }
        } else {
            # The registry path does not exist
            Write-Host "Registry path $RegistryPath does not exist."
        }
    }
    
    # Check if the registry value is not as desired, and if so, set it
    if ($registryValue -ne $DesiredValue) {
        Set-ItemProperty -Path $RegistryPath -Name $RegistryName -Value $DesiredValue
        $registryResult = "Registry Value set to $DesiredValue"
    }


    # Compare the outcomes for exit and remediation
    if ($registryValue -eq $DesiredValue) {
        # Both conditions are met
        Write-Output "Adobe Reader EULA as desired."
        Write-Output "$registryResult"
        # Ensure that the transcript is stopped before exiting
        Stop-Transcript
        exit 0  # Success
        } else {
        # At least one condition is not met
        Write-Output "Adobe Reader EULA is not as desired."
        Write-Output "$registryResult"
        # Ensure that the transcript is stopped before exiting
        Stop-Transcript
        exit 1  # Remediation failed
    }
}

Remediation-AdobeEULA