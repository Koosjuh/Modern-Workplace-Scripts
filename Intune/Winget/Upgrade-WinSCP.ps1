#Create Log folder in userprofile and hide it
$logfolder = "$env:Public\WorkplacePowershellLogs"
$logfile = "Upgrade-Winscp-Winget.log"

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
.\winget.exe upgrade WinSCP.WinSCP --accept-source-agreements --accept-package-agreements --verbose

Stop-Transcript