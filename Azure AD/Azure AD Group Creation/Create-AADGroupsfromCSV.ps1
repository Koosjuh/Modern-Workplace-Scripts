#Requires -Version 5.0

function New-DynamicAADGroupsfromCSV{
    param()

    <#
        .NOTES
        Author:     Koos Janse
        Date:       26/07/2023
        Website:    https://www.koosjanse.com
 

        .SYNOPSIS
        Does exactly what the function name says it does.

        .INPUTS
        CSV File with these 2 headers To-Be-Displayname;MembershipRule
    #>

    #connect to the graph
    Connect-MgGraph -Scopes Group.ReadWrite.All

    #import csv fill in location / path of CSV formatted as stated in .INPUTS
    $groups = Import-Csv -Delimiter ";" -Path "" -Verbose
    

    foreach ($group in $groups) {

        New-MgGroup -DisplayName $($group."To-Be-Displayname") `
        -Description "$($group."To-Be-Displayname") Department Group." `
        -MailEnabled:$False `
        -MailNickName 'group' `
        -SecurityEnabled `
        -GroupTypes DynamicMembership `
        -MembershipRule $group.MembershipRule `
        -MembershipRuleProcessingState On `
        -Verbose
    }

    #disconnect from graph
    Disconnect-MgGraph
}
New-DynamicAADGroupsfromCSV

##############################THESE ARE SEPERATE SCRIPTS###############################################################################################

function New-AssignedAADGroupsfromCSV{
    param()

    <#
        .NOTES
        Author:     Koos Janse
        Date:       26/07/2023
        Website:    https://www.koosjanse.com
 

        .SYNOPSIS
        Does exactly what the function name says it does.

        .INPUTS
        CSV File with these 1 header To-Be-Displayname
    #>

    #connect to the graph
    Connect-MgGraph -Scopes Group.ReadWrite.All

    #import csv fill in location / path of CSV formatted as stated in .INPUTS
    $groups = Import-Csv -Delimiter ";" -Path "" -Verbose
    

    foreach ($group in $groups) {

        New-MgGroup -DisplayName $($group."To-Be-Displayname") `
        -Description "$($group."To-Be-Displayname") Group created: 2023" `
        -MailEnabled:$False `
        -MailNickName 'group' `
        -SecurityEnabled `
        
        Start-Sleep -Seconds 5
    }

    #disconnect from graph
    Disconnect-MgGraph
}
New-AssignedAADGroupsfromCSV