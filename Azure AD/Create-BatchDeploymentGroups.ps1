#Requires -Version 6.0

function New-BatchDeploymentGroups{
    param()

    <#
        .NOTES
        Author:     Koos Janse
        Date:       26/07/2023
        Website:    https://www.koosjanse.com
 

        .SYNOPSIS
        Create security groups for users and devices for an enterprise wide deployment.
    #>

    Connect-MgGraph -Scopes Group.ReadWrite.All

    $hex = @('0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f')

    foreach ($batch in $hex) {
        
        $membershipRuleUser = '(user.objectId -startsWith "{0}")' -f $batch
        $membershipRuleDevice = '(device.objectId -startsWith "{0}")' -f $batch

        New-MgGroup -DisplayName "Batch Deployment $batch Users Dynamic" `
        -Description "This group contains Users for Enterprise Wide Batch deployment. Allowing to evenly deploy something across an organisation." `
        -MailEnabled:$False `
        -MailNickName 'group' `
        -SecurityEnabled `
        -GroupTypes DynamicMembership `
        -MembershipRule $membershipRuleUser `
        -MembershipRuleProcessingState On

        New-MgGroup -DisplayName "Batch Deployment $batch Device Dynamic" `
        -Description "This group contains Users for Enterprise Wide Batch deployment. Allowing to evenly deploy something across an organisation." `
        -MailEnabled:$False `
        -MailNickName 'group' `
        -SecurityEnabled `
        -GroupTypes DynamicMembership `
        -MembershipRule $membershipRuleDevice `
        -MembershipRuleProcessingState On
    }
}