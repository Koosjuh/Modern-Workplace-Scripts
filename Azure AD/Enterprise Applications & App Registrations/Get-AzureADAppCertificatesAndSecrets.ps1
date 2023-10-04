function Get-AzureADAppCertificatesAndSecrets {
    param (
        
        [Parameter(Mandatory = $true)]
        [string] $TenantId,
        
        [Parameter(Mandatory = $true)]
        [string] $OutputCsvPath
    )

    <#
        .NOTES
        Author:     Koos Janse
        Date:       25-09-2023
        Website:    https://www.koosjanse.com
 

        .SYNOPSIS
        Retrieves Azure AD application certificates and secrets along with their expiration dates and exports the data to a CSV file.

        .INPUTS
        - TenantId: The ID of your Azure AD tenant.
        - OutputCsvPath: The path where the CSV file will be saved.
    #>

    # Connect to Microsoft Graph using the appropriate scope
    Connect-MgGraph -Scopes "Application.Read.All"

    # Get list of Azure AD apps
    $apps = Get-MgServicePrincipal -All

    $exportData = @()

    foreach ($app in $apps) {
        $appName = $app.displayName
        $appId = $app.appId
        $serviceprincipaltype = $app.ServicePrincipalType

        foreach ($certificate in $app.keyCredentials) {
            $certificateId = $certificate.keyId
            $expirationDate = $certificate.endDateTime

            $rowData = [PSCustomObject]@{
                "Application Name" = $appName
                "Application ID" = $appId
                "Service Principal Type" = $serviceprincipaltype
                "Type" = "Certificate"
                "ID" = $certificateId
                "Expiration Date" = $expirationDate
            }

            $exportData += $rowData
        }

        foreach ($secret in $app.passwordCredentials) {
            $secretId = $secret.keyId
            $startDate = $secret.startDateTime
            $endDate = $secret.endDateTime

            $rowData = [PSCustomObject]@{
                "Application Name" = $appName
                "Application ID" = $appId
                "Type" = "Secret"
            }

            $exportData += $rowData
        }
    }

    # Export data to a CSV file
    $exportData | Export-Csv -Path $OutputCsvPath -Delimiter ";" -NoTypeInformation

    # Neatly and civalized we disconnect
    Disconnect-MgGraph
}

Get-AzureADAppCertificatesAndSecrets -TenantId "" -OutputCsvPath ""