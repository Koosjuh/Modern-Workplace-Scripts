############
## RULE 1 ##
############
##Check ASR Rule PSEXEC and WMI

# Search for psexec.exe in common system directories
$psexecPath = Get-Command -Name 'psexec.exe' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source

# Search for psexec.exe in user's AppData directory
$currentUserPsexecPath = Join-Path -Path $env:APPDATA -ChildPath 'psexec.exe'
if (Test-Path -Path $currentUserPsexecPath) {
    $psexecPath = $currentUserPsexecPath
}

# If psexec.exe is not found in common directories or user's AppData, search the entire system drive
if (-not $psexecPath) {
    $psexecPath = Get-ChildItem -Path "C:\*" -Recurse -Filter 'psexec.exe' -File -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName -First 1
}

if ($psexecPath) {
    Write-Host "psexec.exe found at: $psexecPath"
} else {
    Write-Host "psexec.exe not found on the device."
}


# Run a harmless command using PSExec to trigger the event
Start-Process -FilePath $psexecPath -ArgumentList "\\$env:COMPUTERNAME -i -s cmd.exe /c echo Hello from PSExec"

############
## RULE 2 ##
############
## Create a hit for WMI Event Subscription
# Create a test WMI event subscription
$Query = "SELECT * FROM __InstanceModificationEvent WITHIN 5 WHERE TargetInstance ISA 'Win32_LogicalDisk' AND TargetInstance.DeviceID = 'C:'"
Register-WmiEvent -Query $Query -SourceIdentifier "TestWMIEvent" -Action {
    Write-Host "Test WMI event triggered"
}

############
## RULE 3 ##
############
# Define the user's Documents folder
$DocumentsFolder = [Environment]::GetFolderPath('MyDocuments')

# Create two test files in the user's Documents folder
$TestFiles = @("$DocumentsFolder\test_file1.txt", "$DocumentsFolder\test_file2.txt")
foreach ($file in $TestFiles) {
    "Test content" | Set-Content -Path $file
}

# Simulate file modification behavior resembling ransomware
foreach ($file in $TestFiles) {
    $content = Get-Content $file
    $newContent = $content + "Ransomware modification"
    $newContent | Set-Content -Path $file
}

# Display a message after modifications
Write-Host "Simulated ransomware modifications done to test files in $DocumentsFolder."

############
## RULE 4 ##
############
# Define the user's Documents folder
$DocumentsFolder = [Environment]::GetFolderPath('MyDocuments')

# Define the path for the protected file within the user's Documents folder
$ProtectedFilePath = Join-Path -Path $DocumentsFolder -ChildPath "protected-file.txt"

# Create the protected file if it doesn't exist
if (-not (Test-Path -Path $ProtectedFilePath)) {
    "Initial content" | Set-Content -Path $ProtectedFilePath
}

# Modify the protected file
$protectedContent = Get-Content $ProtectedFilePath
$newContent = $protectedContent + "Modification in protected file"
$newContent | Set-Content -Path $ProtectedFilePath

# Display a message after modifications
Write-Host "Modified the protected file in $DocumentsFolder."