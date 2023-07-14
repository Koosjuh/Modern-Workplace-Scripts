#Requires -Version 6.0

function Scan-LOLDrivers{
    param(
        [Parameter(Mandatory = $true)]
        [string]$output,
        [string]$filename)

    <#
        .NOTES
        Author:     Koos Janse
        Date:       10/07/2023
        Website:    https://www.koosjanse.com
        I modified the script the original script was written by someone else. 
        #OG Script taken from Repo: 

        .SYNOPSIS
        Scans drivers for known Living of Land Drivers. 

        .DESCRIPTION
        Creates a CSV file that will scan folders for known vulnerable drivers. Recommended to scan atleast the following folders. 
        
        C:\WINDOWS\inf
        C:\WINDOWS\System32\drivers
        C:\WINDOWS\System32\DriverStore\FileRepository 
        
        .PARAMETER Output
        Specifies the directory in which to store the output of the function. Such as a C:\Users\Public. 

        .OUTPUTS
        CSV file with drivers that match against the LOLDriver list.

        .EXAMPLE
        PS> Scan-LOLDrivers -Output "C:\VCE-DriverScan" -path "C:\WINDOWS\System32\drivers"

        .LINK
        Online version: http://www.fabrikam.com/extension.html

        .LINK
        Set-Item
    #>

    Start-Transcript -Path $output\$filename -Append -Verbose

    Add-Type -TypeDefinition @"
    using System;
    using System.Security.Cryptography;
    using System.Security.Cryptography.X509Certificates;
    using System.IO;
    using System.Text;
    
    public class FileHashScanner {
        public static string ComputeSha256(string path) {
            try {
                using (FileStream stream = File.OpenRead(path)) {
                    SHA256Managed sha = new SHA256Managed();
                    byte[] checksum = sha.ComputeHash(stream);
                    return BitConverter.ToString(checksum).Replace("-", String.Empty);
                }
            } catch (Exception) {
                return null;
            }
        }
        public static string GetAuthenticodeHash(string path) {
            try {
                X509Certificate2 cert = new X509Certificate2(path);
                return BitConverter.ToString(cert.GetCertHash()).Replace("-", String.Empty);
            } catch (Exception) {
                return null;
            }
        }
    }
"@

    Write-Host "Downloading drivers.json..."
    $driversJsonUrl = "https://www.loldrivers.io/api/drivers.json"
    $driversJsonContent = Invoke-WebRequest -Uri $driversJsonUrl -UseBasicParsing
    $driverData = $driversJsonContent.Content | ConvertFrom-Json -AsHashtable

    $serializer = [Web.Script.Serialization.JavaScriptSerializer]::new()
    $json = $serializer.Deserialize($jsonstring, [hashtable])
    $json['d']['results']

    Write-Host "Download complete."

    Write-Host "Building correlation tables"
    $fileHashes = @{}
    $authenticodeHashes = @{}
    foreach ($driverInfo in $driverData) {
        foreach ($sample in $driverInfo.KnownVulnerableSamples) {
            'MD5 SHA1 SHA256'.Split() | ForEach-Object {
                $fileHashValue = $sample.$_
                if ($fileHashValue) {
                    $fileHashes[$fileHashValue] = $driverInfo
                }
                $authCodeHashValue = $sample.Authentihash.$_
                if ($authCodeHashValue) {
                    $authenticodeHashes[$authCodeHashValue] = $driverInfo
                }
            }
        }
    }
    Write-Host "Done building correlation tables"

    function Scan-Directory {
        param([string]$directory)
        
        Get-ChildItem -Path $directory -Recurse -File | ForEach-Object {
            $filePath = $_.FullName
            Write-Verbose "Computing hash for $filePath..."
            $fileHash = [FileHashScanner]::ComputeSha256($filePath)
            $fileAuthenticodeHash = [FileHashScanner]::GetAuthenticodeHash($filePath)
            if ($fileHashes.ContainsKey($fileHash)) {
                Write-Host "SHA256 hash match found: $filePath with hash $fileHash (matching $($fileHashes[$fileHash]))"
            }
            if ($fileAuthenticodeHash -and $authenticodeHashes.ContainsKey($fileAuthenticodeHash)) {
                Write-Host "Authenticode hash match found: $filePath with hash $fileAuthenticodeHash (matches $($authenticodeHashes[$fileAuthenticodeHash]))"
            }
        } -Verbose
    }

    $folders = @(
    "C:\WINDOWS\inf",
    "C:\WINDOWS\System32\drivers",
    "C:\WINDOWS\System32\DriverStore\FileRepository")

    foreach($folder in $folders){
    Scan-Directory -directory $folder
    }

    Stop-Transcript
}