#Requires -Version 5.1.19041.3031

function start-leftMenu {
    param ()

    <#
        .NOTES
        Author: Koos Janse
        Date: 
        website: https://www.koosjanse.com
        
        .SYNOPSIS
        Run in Current User Context.

        .DESCRIPTION
        Sets user start menu to the left.
        
        .LINK
        Online version: https://www.koosjanse.com/ 
    #>

    #Create Log folder in userprofile and hide it
    $logfolder = "$env:USERPROFILE\WorkplacePowershellLogs"
    $logfile = "Windows11Startmenu.log"

    if(!(Test-Path -path $logfolder)){
        New-Item -ItemType Directory -Path $logfolder
        Get-Item $logfolder -Force | foreach { $_.Attributes = $_.Attributes -bor "Hidden" }
    }

    Start-Transcript -Path "$env:USERPROFILE\$logfile"
        
    $ErrorActionPreference = 'silentlycontinue'
    
    $explorerPath = "HKCU:Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    
    if(Test-Path $explorerPath -Verbose) {
        Set-ItemProperty -Path $explorerPath -Name TaskbarAl -Value 0 -Verbose
    }
    
    $checkStart = Get-ItemProperty -Path $explorerPath -Name TaskbarAl
        
    if( $checkStart.TaskbarAl -eq 0 ) {  
        Write-Host "Done - Start Menu to the left. KJ160885 code."
    }

    Stop-Transcript
}

start-leftMenu