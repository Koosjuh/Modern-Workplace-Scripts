#Requires -Version 5.1.19041.3031

function Start-SetContext
{
    param ()

    <#
        .NOTES
        Author: Koos Janse
        Date: 
        website: https://www.koosjanse.com
        
        .SYNOPSIS
        Run script in Current User. Sets the windows 10 and 7 context menu in Windows 11. 

        .DESCRIPTION
        https://blog.ironmansoftware.com/powershell-windows-11-context-menu/

    #>

    #Create Log folder in userprofile and hide it
    $logfolder = "$env:USERPROFILE\WorkplacePowershellLogs"
    $logfile = "Windows11Context.log"

    if(!(Test-Path -path $logfolder)){
        New-Item -ItemType Directory -Path $logfolder
        Get-Item $logfolder -Force | foreach { $_.Attributes = $_.Attributes -bor "Hidden" }
    }

    Start-Transcript -Path "$env:USERPROFILE\$logfile"

    #context menu from windows 10 and 7
    New-Item -Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" -Value "" -Force

    #remove widget button
    $explorerPath = "HKCU:Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    
    if(Test-Path $explorerPath) {
        Set-ItemProperty -Path $explorerPath -Name TaskbarDa -Value 0
    }
    $checkChat = Get-ItemProperty -Path $explorerPath -Name TaskbarDa
    if( $checkChat.TaskbarDa -eq 0 ) {
        Write-Host "Done KJ160885 code."
    }

    #Remove Chat
    Get-AppxPackage MicrosoftTeams* | Remove-AppxPackage

    Stop-Transcript

}

Start-SetContext