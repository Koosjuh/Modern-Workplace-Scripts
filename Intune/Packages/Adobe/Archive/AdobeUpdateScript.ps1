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

    #Create Log folder in userprofile and hide it
    $logfolder = "$env:public\WorkplacePowershellLogs"
    $logfile = "Update-Adobe-Remediation.log"

    if(!(Test-Path -path $logfolder)){
        New-Item -ItemType Directory -Path $logfolder
        Get-Item $logfolder -Force | foreach { $_.Attributes = $_.Attributes -bor "Hidden" }
    }

    Start-Transcript -Path "$logfolder\$logfile" -Append
    
    $taskprincipal = New-ScheduledTaskPrincipal -UserId 'NT AUTHORITY\SYSTEM' -RunLevel Highest
    Set-ScheduledTask -TaskName "Adobe Acrobat Update Task" -User $taskprincipal.Userid -Verbose
    
    Stop-Transcript

    exit 0
}

Update-AdobeTaskScheduler