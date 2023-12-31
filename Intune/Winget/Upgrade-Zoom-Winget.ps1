#Create Log folder in userprofile and hide it
$logfolder = "$env:Public\WorkplacePowershellLogs"
$logfile = "Upgrade-Zoom-Winget.log"

if(!(Test-Path -path $logfolder)){
    New-Item -ItemType Directory -Path $logfolder
    Get-Item $logfolder -Force | foreach { $_.Attributes = $_.Attributes -bor "Hidden" }
}

Start-Transcript -Path "$logfolder\$logfile" -Force

$ResolveWingetPath = Resolve-Path "C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller_*_x64__8wekyb3d8bbwe"
    if ($ResolveWingetPath){
           $WingetPath = $ResolveWingetPath[-1].Path
    }

$config

Set-Location $wingetpath
.\winget.exe upgrade --exact --id Zoom.Zoom --silent --force --accept-package-agreements --accept-source-agreements

Stop-Transcript