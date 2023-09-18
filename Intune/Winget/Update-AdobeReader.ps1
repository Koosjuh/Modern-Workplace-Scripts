<#
        .NOTES
        Author: Koos Janse
        Date: 10/08/2023
        website: https://www.koosjanse.com
        
        .SYNOPSIS
        Update Adobe Reader via Winget

        .LINK
        Online version: https://www.koosjanse.com/ 
#>

Start-Transcript -Path "C:\User\public\Winget-adobe-Upgrade.log" -Append -Force -Verbose -IncludeInvocationHeader

    $ResolveWingetPath = Resolve-Path "C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller_*_x64__8wekyb3d8bbwe\winget.exe"
    
    if($ResolveWingetPath){
           $WingetPath = $ResolveWingetPath[-1].Path
    }
    
    $wingetexe = $ResolveWingetPath 

$Wingetpath = Split-Path -Path $WingetPath -Parent

cd $wingetpath

$upgrade = .\winget.exe upgrade --id 'adobe.acrobat.reader.64-bit' --silent --accept-package-agreements --accept-source-agreements --verbose

$upgrade

$upgrade = .\winget.exe upgrade --id 'adobe.acrobat.reader.32-bit' --silent --accept-package-agreements --accept-source-agreements --verbose

$upgrade

Stop-Transcript