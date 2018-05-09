﻿<#
.SYNOPSIS
    This script creates a localhost.mof file which when applied assist in the Enterpriseification [ˈen(t)ərˌprīz-fə-ˈkā-shən] of the Windows 10 Enterprise SKU by removing built-in apps as well as consumer apps settings.
    The localhost.mof will need to be applied via DSC.

    
.DESCRIPTION
    Builds DSC Document to assist in the Enterpriseification of the Windows 10 Enterprise SKU by removing built-in apps as well as consumer apps settings.
    Built and validated on Win10 1607 ONLY.
 
.EXAMPLE
    .\Win10-Enterpriseification_1607.ps1
    Apply the .mof by running the following command:
    cmd.exe /c powershell.exe -executionpolicy bypass Copy-Item -Path C:\AdminCFG\localhost.mof C:\Windows\System32\Configuration\pending.mof -Force; (Invoke-CimMethod -Namespace root/Microsoft/Windows/DesiredStateConfiguration -ClassName MSFT_DSCLocalConfigurationManager -Method PerformRequiredConfigurationChecks -Arguments @{Flags = [System.UInt32]1} -Verbose)

 
.NOTES
 
    Version history:
    1.0.0 - (9-13-2017) Script created
 
.NOTES
    FileName:    Win10-Enterpriseification_1703.ps1
    Author:      Michael A. Henderson
    Contact:     mihend--------------
    Created:     9-13-2017
    Updated:     
    Version:     1.0.0


Resources:
https://blogs.technet.microsoft.com/pstips/2017/03/01/using-dsc-with-the-winrm-service-disabled/
https://docs.microsoft.com/en-us/windows/application-management/apps-in-windows-10


#Apply DSC 
cmd.exe /c powershell.exe -executionpolicy bypass Copy-Item -Path C:\AdminCFG\localhost.mof C:\Windows\System32\Configuration\pending.mof -Force; (Invoke-CimMethod -Namespace root/Microsoft/Windows/DesiredStateConfiguration -ClassName MSFT_DSCLocalConfigurationManager -Method PerformRequiredConfigurationChecks -Arguments @{Flags = [System.UInt32]1} -Verbose)
#Valdate DSC
(Invoke-CimMethod -Namespace root/Microsoft/Windows/DesiredStateConfiguration -ClassName MSFT_DSCLocalConfigurationManager -Method TestConfiguration | foreach {$_.ResourcesInDesiredState, $_.ResourcesNotindesiredstate, $_.ResourceID, $_.InDesiredState, $_.ResourceName, $_.StartDate, $_.RebootRequested}| format-table -AutoSize -wrap -Property ResourceID, InDesiredState, ResourceName, StartDate, RebootRequested)

#>

Configuration Enterpriseification1607 {
    Import-DscResource –ModuleName PSDesiredStateConfiguration
    #Import-DscResource –ModuleName xPSDesiredStateConfiguration
    Node localhost {


Registry CFG-HKLM:DisableConsumerExperiences {

        Ensure = "Present"

        Key = "HKLM:\Software\Policies\Microsoft\Windows\CloudContent"

        Force = $True

        ValueName = "DisableWindowsConsumerFeatures"

        ValueData = "1"

        ValueType = "DWORD" }

Script RemoveWindowsCapabilities {
    GetScript = {#Nothing
    }


TestScript = {
$WindowsCapabilityList =    "App.Support.ContactSupport*",
                            "App.Support.QuickAssist*" 
                            #"Language.Basic~~~en-US~0.0.1.0",       
                            #"Language.Handwriting~~~en-US~0.0.1.0", 
                            #"Language.OCR~~~en-US~0.0.1.0",        
                            #"Language.Speech~~~en-US~0.0.1.0",      
                            #"Language.TextToSpeech~~~en-US~0.0.1.0"  


$WindowsCapList = {$array2}.Invoke()
$WindowsCapList
$WindowsCapList.GetType()

#$WindowsCapList = " "

ForEach ($Capability in $WindowsCapabilityList)
{
$CapabilityName = Get-WindowsCapability -online | Where-Object -property Name -like $Capability | format-table -hidetableheaders Name | Out-string
#if ($CapabilityName.length -ne '0') {write-host $CapabilityName.Trim();write-Verbose "Item in the Windows Capability detected; removing next..."; write-Host "$Capability detected; removing now..."; Return $False 

$CapabilityName = $CapabilityName.Trim()

$WindowsCapList.Add("$CapabilityName")
}

if ($WindowsCapList.Length -ne "0") { write-verbose "Windows Capabiltiy detected, removing now..."; write-Host "Windows Capability detected, removing now..."
    $WindowsCapList = $WindowsCapList | format-table | Out-string
    $WindowsCapList = $WindowsCapList.Trim()
    write-host "Windows Capability detected:
                $WindowsCapList"
                $WindowsCapListValue = "False"

if ($WindowsCapListValue -eq "False") {
               
                Return $False
}
}
Else {
    Write-Verbose "Windows Capabilities already removed."
    Return $True
    }

}


SetScript = {
$WindowsCapabilityList =    "App.Support.ContactSupport*",
                            "App.Support.QuickAssist*" 
                            #"Language.Basic~~~en-US~0.0.1.0",       
                            #"Language.Handwriting~~~en-US~0.0.1.0", 
                            #"Language.OCR~~~en-US~0.0.1.0",        
                            #"Language.Speech~~~en-US~0.0.1.0",      
                            #"Language.TextToSpeech~~~en-US~0.0.1.0"               




ForEach ($Capability in $WindowsCapabilityList)
{
$CapabilityName = Get-WindowsCapability -online | Where-Object -property Name -like $Capability | format-table -hidetableheaders Name | Out-string
$CapabilityName  = $CapabilityName.Trim()

write-host $CapabilityName
if ($CapabilityName)
{
Write-Host "Removing Package: $Capability"
"Removing Package: $Capability" |out-file C:\admincfg\UninstallAppXPackages.txt -append
 
remove-windowscapability -Online -name $CapabilityName -LogPath C:\admincfg\UninstallWindowsCapabilities.log
}
else
{
Write-Host "Unable to find package: $Capability"
"Unable to find package: $Capability" | out-file C:\admincfg\UninstallAppXPackages.txt -append
}

} }}

Script RemoveBuiltInApps {
    GetScript = {#Nothing
    }


TestScript = {
# 1607 AppXProvisionedPackage List
$AppList =  "Microsoft.3DBuilder",                  
            "Microsoft.BingWeather",                 
            "Microsoft.DesktopAppInstaller",       
            "Microsoft.Getstarted",                  
            "Microsoft.Messaging",                   
            "Microsoft.MicrosoftOfficeHub",          
            "Microsoft.MicrosoftSolitaireCollection",
            "Microsoft.MicrosoftStickyNotes",       
            "Microsoft.Office.OneNote",             
            "Microsoft.OneConnect",                 
            "Microsoft.People",                       
            "Microsoft.SkypeApp",                    
            "Microsoft.StorePurchaseApp",           
            #"Microsoft.Windows.Photos",             
            #"Microsoft.WindowsAlarms",               
            #"Microsoft.WindowsCalculator",          
            #"Microsoft.WindowsCamera",              
            "microsoft.windowscommunicationsapps",  
            "Microsoft.WindowsFeedbackHub",         
            "Microsoft.WindowsMaps",                 
            "Microsoft.WindowsSoundRecorder",        
            #"Microsoft.WindowsStore",              
            "Microsoft.XboxApp",                    
            "Microsoft.XboxIdentityProvider",        
            "Microsoft.ZuneMusic",                 
            "Microsoft.ZuneVideo",
            "Microsoft.BingNews",
            "Microsoft.Office.Sway",
            "Microsoft.NetworkSpeedTest",
            "AdobeSystemsIncorporated.AdobePhotoshopExpress",
            "46928bounde.EclipseManager",
            #"Microsoft.Windows.ParentalControls", <--Can not be uninstalled on a per user basis
            #"Microsoft.XboxGameCallableUI",       <--Can not be uninstalled on a per user basis
            "Microsoft.FreshPaint",
            "ActiproSoftwareLLC.562882FEEB491"                  

$PackList = {$array}.Invoke()
$Packlist
$Packlist.GetType()

$ProPackList = {$array1}.Invoke()
$ProPacklist
$ProPacklist.GetType()

$ProPacklistValue = " "
$PacklistValue = " "

ForEach ($App in $AppList)
{
$PackageFullName = (Get-AppxPackage -AllUsers | Where-Object -property Name -eq $App) | format-table -hidetableheaders PackageFullName | Out-string
$PackageFullName = $PackageFullName.Trim()
$ProPackageFullName = (Get-AppxProvisionedPackage -online | Where-Object -property displayname -eq $App)| format-table -hidetableheaders packagename | Out-string
$ProPackageFullName = $ProPackageFullName.Trim()
if ($PackageFullName.Length -ne "0") {
write-host $PackageFullName

$Packlist.Add("$PackageFullName")
}
if ($ProPackageFullName.Length -ne "0") {
write-host $ProPackageFullName

$ProPackList.Add("$ProPackageFullName")

}
}
$Packlist = $Packlist | format-table | Out-string
$Packlist = $Packlist.Trim()
$ProPackList = $ProPackList | format-table | Out-string
$ProPackList = $ProPackList.Trim()

if ($Packlist.Length -ne "0") { write-Verbose "AppxPackages detected; removing now..."; write-Host "AppxPackages detected; removing now..." 
    write-host "AppXPackages detected:
                $Packlist"
                $PacklistValue = "False"
}
if ($ProPacklist.Length -ne "0") { write-verbose "AppxProvisionedPackages detected, removing now..."; write-Host "AppxProvisionedPackages detected, removing now..."
    write-host "AppXProvisionedPackages detected:
                $Packlist"
                $ProPacklistValue = "False"
}
if ($PacklistValue -eq "False" -or $ProPacklistValue -eq "False") {
               
                Return $False
}
Else {
    Write-Verbose "AppxPackages and AppxProvisionedPackages already removed."
    Return $True
    }

}

SetScript = {
Write-Verbose "Remove Specified AppxPackages and AppxProvisionedPackages"
#Remove appxpackages and appxprovisionedpackages
#use Get-AppxPackage or Get-AppxPackage *officehub* to get the name of other packages.

$AppList =  "Microsoft.3DBuilder",                  
            "Microsoft.BingWeather",                 
            "Microsoft.DesktopAppInstaller",       
            "Microsoft.Getstarted",                  
            "Microsoft.Messaging",                   
            "Microsoft.MicrosoftOfficeHub",          
            "Microsoft.MicrosoftSolitaireCollection",
            "Microsoft.MicrosoftStickyNotes",       
            "Microsoft.Office.OneNote",             
            "Microsoft.OneConnect",                 
            "Microsoft.People",                       
            "Microsoft.SkypeApp",                    
            "Microsoft.StorePurchaseApp",           
            #"Microsoft.Windows.Photos",             
            #"Microsoft.WindowsAlarms",               
            #"Microsoft.WindowsCalculator",          
            #"Microsoft.WindowsCamera",              
            "microsoft.windowscommunicationsapps",  
            "Microsoft.WindowsFeedbackHub",         
            "Microsoft.WindowsMaps",                 
            "Microsoft.WindowsSoundRecorder",        
            #"Microsoft.WindowsStore",              
            "Microsoft.XboxApp",                    
            "Microsoft.XboxIdentityProvider",        
            "Microsoft.ZuneMusic",                 
            "Microsoft.ZuneVideo",
            "Microsoft.BingNews",
            "Microsoft.Office.Sway",
            "Microsoft.NetworkSpeedTest",
            "AdobeSystemsIncorporated.AdobePhotoshopExpress",
            "46928bounde.EclipseManager",
            #"Microsoft.Windows.ParentalControls", <--Can not be uninstalled on a per user basis
            #"Microsoft.XboxGameCallableUI",       <--Can not be uninstalled on a per user basis
            "Microsoft.FreshPaint",
            "ActiproSoftwareLLC.562882FEEB491" 
        
 
ForEach ($App in $AppList)
{
$PackageFullName = (Get-AppxPackage -AllUsers | Where-Object -property Name -eq $App) | format-table -hidetableheaders PackageFullName | Out-string
$PackageFullName = $PackageFullName.Trim()
$ProPackageFullName = (Get-AppxProvisionedPackage -online | Where-Object -property displayname -eq $App)| format-table -hidetableheaders packagename | Out-string
$ProPackageFullName = $ProPackageFullName.Trim()
write-host $PackageFullName
Write-Host $ProPackageFullName
if ($PackageFullName)
{
Write-Host "Removing Package: $App"
"Removing Package: $App" |out-file C:\admincfg\UninstallAppXPackages.txt -append

# 1607 Doesnt support -Allusers 
#remove-AppxPackage -package $PackageFullName -AllUsers
remove-AppxPackage -package $PackageFullName
}
else
{
Write-Host "Unable to find package: $App"
"Unable to find package: $App" | out-file C:\admincfg\UninstallAppXPackages.txt -append
}
if ($ProPackageFullName)
{
Write-Host "Removing Provisioned Package: $ProPackageFullName.trim()"
"Removing Provisioned Package: $ProPackageFullName" | out-file C:\admincfg\UninstallAppxProvpackages.txt -append
Remove-AppxProvisionedPackage -online -packagename $ProPackageFullName.Trim()
}
else
{
Write-Host "Unable to find provisioned package: $App" 
 "Unable to find provisioned package: $App" | out-file C:\admincfg\UninstallAppxProvpackages.txt -append
}
} 
}
}

#End of block
}}
Enterpriseification1607 -output C:\AdminCfg
