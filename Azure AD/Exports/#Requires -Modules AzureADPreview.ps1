#Requires -Modules AzureADPreview
#Requires -Version 5.1.19041.3031

function Get-DynamicMS365Groups
{
    param ()

    <#
        .NOTES
        Author: Koos Janse
        Date: 12/07/2023
        website: https://www.koosjanse.com
        
        .SYNOPSIS
        Get Dynamic Security Groups 

        .DESCRIPTION
        This script will connect to AzureAD, get all Dynamic Security Groups in Microsoft Entra. And export themn to a CSV.

        .LINK
        Online version: https://www.koosjanse.com/ 
    #>



    #Connect to Azure AD
    Connect-AzureAD

    import-csv -Path C:\Users\Janse\Downloads\Microsoft365DynamicGroups-Edited.csv

    foreach($group in $groups){
        
    }

    #Get Azure AD Groups and sort them, export them
    Get-AzureADMSGroup -Filter "groupTypes/any(c:c eq 'DynamicMembership')" -All:$true | 
    Where-Object {$_.MembershipRule -like "*"} | 
    Select-Object Id,DisplayName,MembershipRule | 
    Sort-Object DisplayName | 
    Export-Csv $file -NoTypeInformation -NoClobber -Delimiter ";" -Encoding utf8

    #Neatly disconect Azure AD Session
    Disconnect-AzureAD -Verbose
}

