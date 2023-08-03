function Uninstall-AllVersionsofApplication
{
    param ()

    <#
        .NOTES
        Author: Koos Janse
        Date: 02/08/2023
        website: https://www.koosjanse.com
        
        .SYNOPSIS
        Create an array of applications. Check if they exist. If they exist uninstall them.

        .LINK
        Online version: https://www.koosjanse.com/ 
    #>

    $displayNames = @(
    )

    $uninstallKeys64 = Get-ChildItem -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" -ErrorAction SilentlyContinue

    $uninstallKeys32 = Get-ChildItem -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall" -ErrorAction SilentlyContinue

    $uninstallKeys = $uninstallKeys64 + $uninstallKeys32

    foreach ($key in $uninstallKeys) {
        if ($key.GetValue("Displayname") -in $displayNames) {
            Write-Host "Found Tableau version: ($key.getvalue("Version")"
            
            $path = $key.name

            $GUID = ($path| Select-String -Pattern '{.*?}').Matches.Value

            $arguments = "/x $GUID /q"
            Write-Host "Uninstalling with command: msiexec $arguments"
            $uninstall = Start-Process -FilePath "msiexec" -ArgumentList $arguments -Wait -PassThru -Verbose

            $uninstall
        }
    }
}