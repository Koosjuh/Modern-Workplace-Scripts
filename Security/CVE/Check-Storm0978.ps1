#Requires -Version 6.0
#Requires -RunAsAdministrator

function Get-Storm0978Status{
    param(
        [Parameter(Mandatory = $true)]
        [string]$output,
        [string]$workspaceId,
        [string]$sharedKey
        )

    <#
        .NOTES
        Author:     Koos Janse
        Date:       16/07/2023
        Website:    https://www.koosjanse.com
        

        .SYNOPSIS
        Runs through a checklist to see what needs to be configured to not be vulnerable against this attack.

        .DESCRIPTION
        It checks for the following items and tests them. Outputting a table with actions to be taken.

        -Cloud Delivered Protection
        -EDR Block Mode
            If all these checks are passed and you update your environment every month this should be available in Defender 365
        -Investigation and remedition in Defender 365 Safe attachments and safe links (ZAP)
        -Block Process creations originating from PSExecs and WMI
        -Block executable files from running unless they meet a prevalence, age, or trusted list criterion
        -Use advanced protection against ransomware
        -Block all Office applications from creating child processes

        Below are the guids listed and 1 means enabled and 2 means enabled and locked so user can not change it.

        To have the log analytics part running an Azure Monitoring Agent or Microsoft Monitoring Agent needs to be deployed to the devices. These Agents have shared keys and you need to 
        paste the Primary key. Workspace ID is the id of the workspace you want to send the logs to.
        
        .PARAMETER Output
        Specifies the directory in which to store the output of the function. Such as a C:\Users\Public. 

        .OUTPUTS
        2 local files a Log file and Transcript. With the following name: Storm-0978_Runtime_(YEAR-Month-Day).log
        JSON Data for Log Analytics in Azure.

        .EXAMPLE
        PS> Get-Storm0978 -Output "C:\User\Public" -workspaceid 815158-1SAF235t-saRF252 -sharkedkey 02567u802sadgf3qy6gargtyw34

        .LINK
        write up can be found: http://www.koosjanse.com
    #>

    $filename = "Storm-0978_Runtime_$(get-date -f yyyy-MM-dd).log"

    Start-Transcript -Path $output\$filename -Append -Verbose

    $securityChecks = @()

    # Cloud Delivered Protection
    $mapsReporting = (Get-MpPreference).MapsReporting
    $cloudDeliveredProtection = $mapsReporting -eq 2 -or 1
    $securityChecks += @{
        'Check' = 'Cloud Delivered Protection'
        'Status' = $cloudDeliveredProtection
    }

    # Blocked Processes from PSExecs and WMI d1e49aac-8f56-4280-b9ba-993a6d77406c

    $registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Policy Manager"
    $PSEXEC = Get-ItemProperty -Path $registryPath -Name "ASRRules"

    $psexecRulesFound = $PSEXEC."ASRRules" -like "*d1e49aac-8f56-4280-b9ba-993a6d77406c=1*" -or $PSEXEC."ASRRules" -like "*d1e49aac-8f56-4280-b9ba-993a6d77406c=2*"

    $securityChecks += @{
        'Check' = 'PSEXEC and WMI Blocked processes'
        'Status' = $psexecRulesFound
    }

    # Block executable files from running unless they meet a prevalence, age, or trusted list criterion 01443614-cd74-433a-b99e-2ecdc07bfc25
    $registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Policy Manager"
    $asrRules = Get-ItemProperty -Path $registryPath -Name "ASRRules"

    $asrRulesFound = $asrRules."ASRRules" -like "*01443614-cd74-433a-b99e-2ecdc07bfc25=1*" -or $asrRules."ASRRules" -like  "*01443614-cd74-433a-b99e-2ecdc07bfc25=2*"

    $securityChecks += @{
        'Check' = 'Block executable files from running unless they meet a prevalence, age, or trusted list criterion'
        'Status' = $asrRulesFound
    }


    # Advanced protection against ransomware
    $advancedProtectionEnabled = (Get-MpPreference).EnableControlledFolderAccess
    $advancedProtectionSecCheck = $advancedProtectionEnabled -eq 1 -or $advancedProtectionEnabled -eq 2

    $securityChecks += @{
        'Check' = 'Advanced Protection against Ransomware'
        'Status' = $advancedProtectionSecCheck
    }

    # Blocking of Child Processes for Office Applications
    $officeChildProcessEnabled = $asrRules."ASRRules" -like  "*d4f940ab-401b-4efc-aadc-ad5f3c50688a=1*" -or $asrRules."ASRRules" -like  "*d4f940ab-401b-4efc-aadc-ad5f3c50688a=2*"

    $securityChecks += @{
    'Check' = 'Blocking of Child Processes for Office Applications'
    'Status' = $officeChildProcessEnabled
    }

    # Overall vulnerability status
    $vulnerable = $securityChecks | Where-Object { $_.Status -eq $False }
    $overallStatus = if ($vulnerable.Count -gt 0) { 'Vulnerable' } else { 'Protected' }

    # Create log file
    $logFile = @{
        'User' = $env:USERNAME
        'DeviceName' = $env:COMPUTERNAME
        'VulnerabilityStatus' = $overallStatus
        'SecurityChecks' = $securityChecks
    } | ConvertTo-Json

    $logFile | Out-File -FilePath "$output\Storm-0978_AzLogAn_$(get-date -f yyyy-MM-dd).log" -Encoding UTF8 -Append

    # Output vulnerability status
    Write-Host "Device is $overallStatus"

    # Output log file path
    Write-Host "Log file path: $output\Storm-0978_AzLogAn_$(get-date -f yyyy-MM-dd).log"
    Write-Host "Transcript of script path: $output\$filename"

    Write-Host("LOG ANALYTICS ")
    ## LOG ANALYTICS 
    $apiVersion = "2016-04-01"
    $logType = "MyCustomLog"

    # Read the JSON file
    $jsonFilePath = "$output\Storm-0978_AzLogAn_$(get-date -f yyyy-MM-dd).log"
    $jsonContent = Get-Content -Path $jsonFilePath -Raw

    # Create the authorization header
    $date = [System.DateTime]::UtcNow.ToString("r")
    $contentType = "application/json"
    $stringToHash = "POST`n$jsonContent`n$contentType`n$date`n/api/logs"
    $utf8Encoding = New-Object System.Text.UTF8Encoding
    $hasher = New-Object System.Security.Cryptography.HMACSHA256
    $hasher.Key = [Convert]::FromBase64String($sharedKey)
    $hashedBytes = $hasher.ComputeHash($utf8Encoding.GetBytes($stringToHash))
    $signature = [Convert]::ToBase64String($hashedBytes)
    $authorizationHeader = "SharedKey ${workspaceId}:${signature}"

    # Send the data to Log Analytics
    $uri = "https://$workspaceId.ods.opinsights.azure.com/api/logs?api-version=$apiVersion"
    Invoke-RestMethod -Method Post -Uri $uri -Headers @{
        "Authorization" = $authorizationHeader
        "Log-Type" = $logType
        "x-ms-date" = $date
        #"time-generated-field" = ""  # Replace with the name of the timestamp field in your JSON data
    } -ContentType $contentType -Body $jsonContent

    Write-Host("Remediation")
    ##Remediation
    try {
        # Check if the "VulnerabilityStatus" is "Protected"
        if ($overallStatus -eq "Protected") {
            Write-Host "Vulnerability Status: Protected"
            Stop-Transcript
            # Exit with code 0 (success)
            Exit 0
        } else {
            Write-Host "Vulnerability Status: Not Protected"
            Stop-Transcript
            # Exit with code 1 (failure)
            Exit 1
        }
    }
    catch {
        Write-Host "Error reading or processing the log file."
        Stop-Transcript
        # Exit with code 1 (failure)
        Exit 1
    }

    Stop-Transcript
}