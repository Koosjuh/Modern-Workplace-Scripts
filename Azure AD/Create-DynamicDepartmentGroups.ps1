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

        .LINK
        Online version: https://www.koosjanse.com/ 
    #>

    #Connect to Azure AD
    Connect-AzureAD

    #Create array of unique departments. Using the variable in the mailnickname parameter may cause it to error. Check department name for spaces, commas or other characters that are not allowed to be in a mail alias. 
    $departmentarray = Get-AzureADUser -All:$True | Select-Object -ExpandProperty department | Sort-Object  -unique

    #Start processing and creating dynamic groups
    foreach ($department in $departmentarray){

        #Vars for naming convention Check for spaces and commas etc.
        $displayname = "$department | Department"
        $mailnickname = "MW-$department-DynamicGroup"
        
        #Create new Azure AD Dynamic Group based on Department and vars
        New-AzureADMSGroup -DisplayName $displayname -Description "Dynamic Group for department: $department" -MailEnabled $False -MailNickname $mailnickname -SecurityEnabled $True -GroupTypes "DynamicMembership" -membershipRule "(user.department -contains ""$department"")" -membershipRuleProcessingState "On" -Verbose

    }

    #Neatly disconect Azure AD Session
    Disconnect-AzureAD -Verbose
}