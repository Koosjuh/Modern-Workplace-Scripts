#Requires -Modules AzureAD
#Requires -Version 6.0

function Create-DynamicDepartmentGroups
{
    param ()

    <#
        .NOTES
        Author: Koos Janse
        Date: 04/07/2023
        website: https://www.koosjanse.com
        
        .SYNOPSIS
        Create Dynamic Security Groups 

        .DESCRIPTION
        This script will connect to AzureAD, create an array of all unique departments found in Azure AD. After it found all departments it will create dynamic groups according to a name convention you declare. 

        .PARAMETER Name
        Specificies the naming convention groups will be called.

        .LINK
        Online version: https://www.koosjanse.com/ 
    #>

    #Connect to Azure AD
    Connect-AzureAD

    #Create array of unique departments.
    $departmentarray = Get-AzureADUser -All:$True | Select-Object -ExpandProperty department | Sort-Object  -unique

    #Start processing and creating dynamic groups
    foreach ($department in $departmentarray){

        #Vars for naming convention
        $displayname = "$department | Department"
        $mailnickname = "Fabrikam-Department-$department-DynamicGroup"
        
        #Create new Azure AD Dynamic Group based on Department and vars
        New-AzureADMSGroup -DisplayName $displayname -Description "Dynamic Group for department: $department" -MailEnabled $False -MailNickname $mailnickname -SecurityEnabled $True -GroupTypes "DynamicMembership" 
        -membershipRule "(user.department -contains ""$department"")" -membershipRuleProcessingState "On" -Verbose
      
    }

    #Neatly disconect Azure AD Session
    Disconnect-AzureAD -Verbose
}