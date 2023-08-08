#Requires -Version 6.0

function New-BatchDeploymentGroups{
    param()

    <#
        .NOTES
        Author:     Koos Janse
        Date:       1/08/2023
        Website:    https://www.koosjanse.com
 

        .SYNOPSIS
        Create security groups based on device ownership from a user object/Grouped userobject.
    #>

    Connect-MgGraph -Scopes Microsoft.Graph.Group
    
    $group = Get-MgGroupMember -GroupId 57975938-4a5c-4ba3-8d9d-71168dee20d9
    
    foreach ($user in $group) {
        
        $userdevices = Get-MgUserOwnedDevice -UserId $user.id
        
        if($userdevices){
            foreach($device in $userdevices){
                New-MgGroupMember -GroupId "b95ee33a-5e47-4885-b30b-0ff48b9fc066" -DirectoryObjectId $device.id
            }
        }else{
            $Displayname = Get-MgUser -UserId $user.id | Select-Object -Property Displayname
            Write-Host("$displayname does not have a device.")
        }
    }
}