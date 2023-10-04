function Get-DepartmentMembersInGroups {
    param (
        [string]$ApplicationID,
        [string]$DepartmentToCheck
    )

    <#
        .NOTES
        Author:     Koos Janse
        Date:       25-09-2023
        Website:    https://www.koosjanse.com

        .SYNOPSIS
        This function checks if users from a specified department are members of any groups assigned to an Enterprise application.

        .DESCRIPTION
        This function queries the assigned groups for the specified Enterprise application and checks if any users from the specified department are members of those groups. The results are exported to a CSV file.

        .PARAMETER ApplicationID
        The Application ID of the Enterprise application you want to check.

        .PARAMETER DepartmentToCheck
        The name of the department you want to check for membership.

        .PARAMETER OutputCSVPath
        The path where the results will be saved as a CSV file.

        .EXAMPLE
        Get-DepartmentMembersInGroups -EnterpriseAppName "Salesforce" -DepartmentToCheck "Financial Planning and Analysis"
    #>

    # Authenticate using Connect-MgGraph
    Connect-MgGraph -Scopes "Group.Read.All", "User.Read.All,Application.Read.All"

    # Initialize an array to store the results
    $results = @()

    # Get the list of Enterprise Applications
    $applications = Get-MgServicePrincipal -all | Where-Object { $_.AppId -eq "$ApplicationID" }

    # Loop through each application
    foreach ($app in $applications) {
        # Get the list of app role assignments for the application
        $appRoles = Get-MgServicePrincipalAppRoleAssignedTo -ServicePrincipalId $app.Id

        # Loop through each app role assignment
        foreach ($appRole in $appRoles) {
            # Get the group details
            $group = Get-MgGroup -Filter "displayName eq '$($appRole.PrincipalDisplayName)'"
            $groupMembers = Get-MgGroupMember -GroupId $group.Id
    
            foreach($member in $groupmembers){
            $member.Id

            # Check if the group has members from the specified department
            $membercheck = Get-MgUser -UserId $member.id

                if($membercheck.department -eq $DepartmentToCheck){
                        # Add the result to the results array
                        $result = [PSCustomObject]@{
                        'GroupDisplayName' = $group.DisplayName
                        'User Name' = $member.Id
                        }
                    $results += $result
                }    
            }
        }

    # Output the results to a CSV file
    $results | Export-Csv -Path "C:\users\public\$ApplicationID-$DepartmentToCheck.csv" -NoTypeInformation

    # Neatly disconnect from Microsoft Graph
    Disconnect-MgGraph
}

Get-DepartmentMembersInGroups -EnterpriseAppName "Salesforce" -DepartmentToCheck "Strategy, Planning and Analysis"