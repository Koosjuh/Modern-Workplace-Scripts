#Requires -Version 6.0

function Remediate-Zoom
{
    param ()

    <#
        .NOTES
        Author:     Koos Janse
        Date:       18/09/2023
        Website:    https://www.koosjanse.com

        .DESCRIPTION
        Update existing package via WinGet
    #>

    #Create Log folder and hide it
    $logfolder = "$env:Public\WorkplacePowershellLogs"
    $logfile = "Remediate-.log"

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
    .\winget.exe upgrade --exact --id Zoom.Zoom --silent --accept-package-agreements --accept-source-agreements --scope machine

    $wingetcmd = .\winget.exe upgrade --exact --id Zoom.Zoom --silent --accept-package-agreements --accept-source-agreements --scope machine

    if($wingetcmd -contains "No available upgrade found."){
        Write-Host("No available upgrade found. All is good.")
        Write-Host("$wingetcmd")
        Stop-Transcript        
    }else{
        Write-Host("")
        Write-Host("$wingetcmd")
        Stop-Transcript
    }


}

Remediate-Zoom