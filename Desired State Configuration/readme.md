# Setting Up Azure AD Application Registration for Desired State Configuration (DSC)

This README.md guide outlines the steps to create an Azure AD application registration with specific permissions using PowerShell.

## Prerequisites

Before you begin, make sure you have the following prerequisites in place:

- [Azure PowerShell module](https://docs.microsoft.com/en-us/powershell/azure/install-az-ps)
- Administrator access to Azure AD and Intune.

## Application Registration

Follow these steps to create an Azure AD application registration:

1. Open a PowerShell session and run the following script to create a self-signed certificate and export it:

   ```powershell
   $appDisplayName = "MS-DSC"
   $domain = "w3rmd.onmicrosoft.com"
   $filename = $domain -replace '[^a-zA-Z0-9]', '_'

   $Cert = New-SelfSignedCertificate -DnsName $domain -CertStoreLocation "Cert:\LocalMachine\My" -FriendlyName $appDisplayName -Subject "Cert for Microsoft Graph SDK - Desired State Configuration" -KeyExportPolicy Exportable

   Export-Certificate -Cert $Cert -FilePath "C:\Users\Public\$filename.cer"


To set up an Azure AD application registration:

1. Sign in to the Azure portal using your Azure AD administrator account.

2. Navigate to "Azure Active Directory" and select "App registrations."

3. Click on "New registration" to create a new application registration.

4. Provide a name for your application (e.g., "MS-DSC") and choose the appropriate supported account types.

5. In the "Redirect URI" section, you can leave this default.

6. Click "Register" to create the application.

7. After the application is created, note down the "Application (client) ID" as it will be used in your PowerShell scripts.

**Permissions Configuration:**

Open Powershell and use the following: Update-M365DSCAllowedGraphScopes -All -Type 'Update' -Environment 'Global'

**Authentication Configuration:**
Use the certificate you created earlier.

**Conclusion:**

You've now set up an Azure AD application registration with the necessary permissions for your Desired State Configuration (DSC) requirements. You can use the client ID, certificate, or secret in your DSC scripts for authentication and to perform the desired actions.

For further integration and customization of your DSC setup, refer to the Microsoft Graph API documentation and Intune API documentation as needed.