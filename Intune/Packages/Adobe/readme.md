# Adobe Reader EULA and Task Schedule Principal Detection and Remediation

## Overview

This Detection and Remediation package is designed to ensure compliance with two critical aspects of an Adobe Reader deployment: the acceptance of the End-User License Agreement (EULA) registry key and the Task Schedule Principal. The package consists of both a detection script and a remediation script, which can be utilized in a Microsoft Intune environment to maintain a secure and compliant Adobe Reader installation.

### Components

    Detection Script (Detection-TaskPrincipal-EULA.ps1):
        
        This script checks the following conditions:
            The existence of the EULA registry key under HKCU:\SOFTWARE\Adobe\Acrobat Reader\DC\AdobeViewer.
            The value of the EULA registry key (should be 1 for accepted).
            The Task Schedule Principal for the "Adobe Acrobat Update Task" (should be "SYSTEM").

        Based on the results of these checks, it returns an exit code:
            0 (Success): Both conditions are met.
            1 (Remediation required): At least one condition is not met.

    Remediation Script (Remediate-TaskPrincipal-EULA.ps1):
            This script remediates the detected non-compliance issues:
            Sets the EULA registry key to 1 if it's not already set.
            Sets the Task Schedule Principal for the "Adobe Acrobat Update Task" to "SYSTEM" if it's not already set.
        
        It also provides verbose logging for each step.

### Usage

    Detection:
        Upload the Detection-TaskPrincipal-EULA.ps1 script as a PowerShell script in Microsoft Intune.
        Create a Configuration Profile for detection using the script.
        Set the compliance rule to check if the script returns exit code 0.

    Remediation:
        Upload the Remediate-TaskPrincipal-EULA.ps1 script as a PowerShell script in Microsoft Intune.
        Create a Configuration Profile for remediation using the script.
        Set the assignment to run the remediation script if the detection script returns a non-compliant status (exit code 1).

    Logging:
        Both scripts create logs in the user's profile ($env:Public\WorkplacePowershellLogs) and hide the log folder.
        Logs are stored in the Update-Adobe-Detection.log and Update-Adobe-Remediation.log files.

### Workflow

    The Detection Script checks the compliance status:
        Checks the EULA registry key and value.
        Checks the Task Schedule Principal for the "Adobe Acrobat Update Task."

    If the Detection Script finds any non-compliance issues:
        The Remediation Script is triggered to:
            Set the EULA registry key to 1.
            Set the Task Schedule Principal to "SYSTEM."

    After remediation, there will be done a final check:
        If both conditions are now met, the script exits with 0 (Success).
        If any condition is still not met, the script exits with 1 (Remediation failed).

## Conclusion

This Detection and Remediation package for Adobe Reader EULA and Task Schedule Principal helps maintain a secure and compliant Adobe Reader installation by detecting and remediating non-compliance issues automatically. It ensures that the EULA is accepted, and the Task Schedule Principal is correctly set to "SYSTEM."