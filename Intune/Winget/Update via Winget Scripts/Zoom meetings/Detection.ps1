#Requires -Version 6.0

function Detect-Zoom
{
    param ()

    <#
        .NOTES
        Author:     Koos Janse
        Date:       <Date> 
        Website:    https://www.koosjanse.com

        .SYNOPSIS
        Adds a file name extension to a supplied name.

        .DESCRIPTION
        Adds a file name extension to a supplied name.
        Takes any strings for the file name or extension.

        .PARAMETER Name
        Specifies the file name.

        .PARAMETER Extension
        Specifies the extension. "Txt" is the default.

        .INPUTS
        None. You cannot pipe objects to Add-Extension.

        .OUTPUTS
        System.String. Add-Extension returns a string with the extension or file name.

        .EXAMPLE
        PS> extension -name "File"
        File.txt

        .EXAMPLE
        PS> extension -name "File" -extension "doc"
        File.doc

        .EXAMPLE
        PS> extension "File" "doc"
        File.doc

        .LINK
        Online version: http://www.fabrikam.com/extension.html

        .LINK
        Set-Item
    #>

    #Create Log folder in userprofile and hide it
    $logfolder = "$env:Public\WorkplacePowershellLogs"
    $logfile = "Detect-Zoom-Winget.log"

    if(!(Test-Path -path $logfolder)){
        New-Item -ItemType Directory -Path $logfolder
        Get-Item $logfolder -Force | foreach { $_.Attributes = $_.Attributes -bor "Hidden" }
    }

    Start-Transcript -Path "$logfolder\$logfile" -Append

    $ResolveWingetPath = Resolve-Path -path "C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller_*_x64__8wekyb3d8bbwe"

    if ($ResolveWingetPath){
           $WingetPath = $ResolveWingetPath[-1].Path
    }

    Set-Location $wingetpath
    $wingetcmd = .\winget.exe upgrade --exact --id Zoom.Zoom --silent --accept-package-agreements --accept-source-agreements --scope machine

    if($wingetcmd -contains "No installed package found matching input criteria."){
        Write-Host("No installed package found matching input criteria. All is good.")
        Write-Host("$wingetcmd")
        Stop-Transcript
        exit 0
    }if($wingetcmd -contains "No available upgrade found."){
        Write-Host("No available upgrade found. All is good.")
        Write-Host("$wingetcmd")
        Stop-Transcript
        exit 0
        
    }else{
        Write-Host("Something else kicking off remediation.")
        Write-Host("$wingetcmd")
        Stop-Transcript
        exit 1
    }

}

Detect-Zoom