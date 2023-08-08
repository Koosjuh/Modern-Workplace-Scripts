#Requires -Modules Microsoft.Graph.Identity.Governance, Microsoft.Graph.Authentication
#Requires -Version 6.0

function Remove-AccessPackageAssignments
{
    param ()

    <#
        .NOTES
        Author: Koos Janse
        Date: 11/07/2023
        website: https://www.koosjanse.com
        
        .SYNOPSIS
        Remove users from access package in bulk.

        .LINK
        Online version: https://www.koosjanse.com/ 
    #>

    #Connect to the Graph
    Connect-MgGraph -Scopes "EntitlementManagement.ReadWrite.All"

    #Select the appropiate profile.
    Select-MgProfile -Name "beta"
       
    #Please provide the objectid of the access package. This can be viewed from the Access Package menu and in the Overview tab.
    $accesspkgobjectid = ""
    
    # Please provide a csv with user principal names / email addresses. 
    # Example would be $members = Get-Content -path "C:\Users\Public\list.csv"
    $members = Get-Content -Path ""
    
    #This is where the magic happens. Please always use caution when using scripts. Please make sure you read it and understand the purpose. Also Might want to do a single test before using a foreach loop. :)
    foreach ($member in $members){
        $assignments = Get-MgEntitlementManagementAccessPackageAssignment -Filter "accessPackageId eq '$accesspkgobjectid' and assignmentState eq 'Delivered'" -All -ErrorAction Stop
        $user = Get-AzureADUser -Searchstring "$Member"    
        $toRemove = $assignments | Where-Object {$_.targetId -eq $user.objectId}
        New-MgEntitlementManagementAccessPackageAssignmentRequest -AccessPackageAssignmentId $toRemove.Id -RequestType "AdminRemove" -Verbose
    }
}