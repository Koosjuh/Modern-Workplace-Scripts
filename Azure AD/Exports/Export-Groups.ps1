#Requires -Modules exchangepowershell
#Requires -Version 6.0
function Name-Function
{
    param ()

    <#
        .NOTES
        Author:     Koos Janse
        Date:       <Date> 
        Website:    https://www.koosjanse.com

        .SYNOPSIS
        Adds a file name extension to a supplied name.

        .DESCRIPTION
        Adds a file name extension to a supplied name.
        Takes any strings for the file name or extension.

        .PARAMETER Name
        Specifies the file name.

        .PARAMETER Extension
        Specifies the extension. "Txt" is the default.

        .INPUTS
        None. You cannot pipe objects to Add-Extension.

        .OUTPUTS
        System.String. Add-Extension returns a string with the extension or file name.

        .EXAMPLE
        PS> extension -name "File"
        File.txt

        .EXAMPLE
        PS> extension -name "File" -extension "doc"
        File.doc

        .EXAMPLE
        PS> extension "File" "doc"
        File.doc

        .LINK
        Online version: http://www.fabrikam.com/extension.html

        .LINK
        Set-Item
    #>
    
    foreach($group in $groups){
        if($group.SecurityEnabled -eq $false){
            $dynamicDistributionGroups += $group
        }
    }