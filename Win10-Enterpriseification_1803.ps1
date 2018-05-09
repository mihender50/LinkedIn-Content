<#
.SYNOPSIS
    This script creates a localhost.mof file which when applied assist in the Enterpriseification [ˈen(t)ərˌprīz-fə-ˈkā-shən] of the Windows 10 Enterprise SKU by removing built-in apps as well as consumer apps settings.
    The localhost.mof will need to be applied via DSC.

   


 
.DESCRIPTION
    Builds DSC Document to assist in the Enterpriseification of the Windows 10 Enterprise SKU by removing built-in apps as well as consumer apps settings.
    Built and validated on Win10 1709 ONLY.
 
.EXAMPLE
    .\Win10-Enterpriseification_1709.ps1
    Apply the .mof by running the following command:
    cmd.exe /c powershell.exe -executionpolicy bypass Copy-Item -Path C:\AdminCFG\localhost.mof C:\Windows\System32\Configuration\pending.mof -Force; (Invoke-CimMethod -Namespace root/Microsoft/Windows/DesiredStateConfiguration -ClassName MSFT_DSCLocalConfigurationManager -Method PerformRequiredConfigurationChecks -Arguments @{Flags = [System.UInt32]1} -Verbose)

 
.NOTES
 
    Version history:
    1.0.0 - (5-9-2018) Script created
 
.NOTES
    FileName:    Win10-Enterpriseification_1709.ps1
    Author:      Michael A. Henderson
    Contact:     www.linkedin.com/in/michael-henderson-6003398
    Created:     5-9-2018
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

Configuration Enterpriseification1709 {
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

#Hide Gaming Settings
Registry CFG-HideGaming {

        Ensure = "Present"

        Key = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer"

        Force = $True

        ValueName = "SettingsPageVisibility"

        ValueData = "Hide:gaming-gamebar;gaming-gamedvr;gaming-broadcasting;gaming-gamemode"

        ValueType = "String" }

Script RemoveWindowsCapabilities {
    GetScript = {#Nothing
    }


TestScript = {

# (Get-WindowsCapability -online | Where-Object {$_.name -ne $Null -and $_.state -eq "Installed"})| format-table -hidetableheaders Name | Out-string
#Updated for 1803
$WindowsCapabilityList =    "App.Support.QuickAssist*"   
                            #"Browser.InternetExplorer*", 
                            #"Language.Basic~~~en-US~0.0.1.0",       
                            #"Language.Handwriting~~~en-US~0.0.1.0", 
                            #"Language.OCR~~~en-US~0.0.1.0",         
                            #"Language.Speech~~~en-US~0.0.1.0",      
                            #"Language.TextToSpeech~~~en-US~0.0.1.0",
                            #"Language.UI.Client~~~en-US~",          
                            #"Media.WindowsMediaPlayer~~~~0.0.12.0", 
                            #"OneCoreUAP.OneSync~~~~0.0.1.0"
                            #OpenSSH.Client~~~~0.0.1.0 


$WindowsCapList = {$array2}.Invoke()
$WindowsCapList
$WindowsCapList.GetType()

#$WindowsCapList = " "

ForEach ($Capability in $WindowsCapabilityList)
{
#$CapabilityName = Get-WindowsCapability -online | Where-Object -property Name -like $Capability | format-table -hidetableheaders Name | Out-string
$CapabilityName = Get-WindowsCapability -online | where-object {$_.name -like $Capability -and $_.state -eq "Installed"} | format-table -hidetableheaders Name | Out-string

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
$DateTime = Get-Date -format g
#$logpath = "C:\admincfg\UninstallWindowsCapabilities.log"
$logpathappx = "C:\admincfg\UninstallAppXPackages.log"

$WindowsCapabilityList =    "App.Support.QuickAssist*"   
                            #"Browser.InternetExplorer*", 
                            #"Language.Basic~~~en-US~0.0.1.0",       
                            #"Language.Handwriting~~~en-US~0.0.1.0", 
                            #"Language.OCR~~~en-US~0.0.1.0",         
                            #"Language.Speech~~~en-US~0.0.1.0",      
                            #"Language.TextToSpeech~~~en-US~0.0.1.0",
                            #"Language.UI.Client~~~en-US~",          
                            #"Media.WindowsMediaPlayer~~~~0.0.12.0", 
                            #"OneCoreUAP.OneSync~~~~0.0.1.0"
                            #OpenSSH.Client~~~~0.0.1.0              




ForEach ($Capability in $WindowsCapabilityList)
{
$CapabilityName = Get-WindowsCapability -online | Where-Object -property Name -like $Capability | format-table -hidetableheaders Name | Out-string
$CapabilityName  = $CapabilityName.Trim()

write-host $CapabilityName
if ($CapabilityName)
{
$DateTime = Get-Date -format g
Write-Host "Removing Package: $Capability"
"$DateTime Removing Package: $Capability" |out-file $logpathappx -append
 
remove-windowscapability -Online -name "$CapabilityName" -LogPath "C:\admincfg\UninstallWindowsCapabilities.log"

}
else
{
$DateTime = Get-Date -format g
Write-Host "Unable to find package: $Capability"
" $DateTime Unable to find package: $Capability" | out-file $logpathappx -append
}

} }}

Script RemoveBuiltInApps {
    GetScript = {#Nothing
    }


TestScript = {
# 1803 AppXProvisionedPackage List
#(Get-AppxPackage | Where-Object -property Name -like *) | format-table -hidetableheaders Name | Out-string
#(Get-AppxProvisionedPackage -online | Where-Object -property displayname -like *)| format-table -hidetableheaders DisplayName | Out-string
# Commended out AppxProvisioned packages which you may want to keep
$AppList =     #"Microsoft.BingWeather",
                "Microsoft.DesktopAppInstaller",
                "Microsoft.GetHelp",
                "Microsoft.Getstarted",
                "Microsoft.Messaging", 
                "Microsoft.Microsoft3DViewer",
                "Microsoft.MicrosoftOfficeHub",
                "Microsoft.MicrosoftSolitaireCollection",
               #"Microsoft.MicrosoftStickyNotes",
               #"Microsoft.MSPaint",
               #"Microsoft.Office.OneNote",
                "Microsoft.OneConnect",
                "Microsoft.People",
               #"Microsoft.Print3D",
                "Microsoft.SkypeApp",
                "Microsoft.StorePurchaseApp",
                "Microsoft.Wallet",
               #"Microsoft.Windows.Photos",
               #"Microsoft.WindowsAlarms",
               #"Microsoft.WindowsCalculator",
               #"Microsoft.WindowsCamera",
                "microsoft.windowscommunicationsapps",
                "Microsoft.WindowsFeedbackHub",
               #"Microsoft.WindowsMaps",
               #"Microsoft.WindowsSoundRecorder",
               #"Microsoft.WindowsStore",
                "Microsoft.Xbox.TCUI",
                "Microsoft.XboxApp",
                "Microsoft.XboxGameOverlay",
                "Microsoft.XboxIdentityProvider",
                "Microsoft.XboxSpeechToTextOverlay",
                "Microsoft.ZuneMusic",
                "Microsoft.ZuneVideo",
                #AppXpackages
                #"Microsoft.Windows.CloudExperienceHost",          <--Unable to Remove
                #"Microsoft.Windows.ContentDeliveryManager",       <--Unable to Remove
                #"Microsoft.Windows.HolographicFirstRun",          <--Unable to Remove
                #"Microsoft.Windows.ParentalControls",             <--Unable to Remove
                #"Microsoft.Windows.PeopleExperienceHost",         <--Unable to Remove
                #"Microsoft.XboxGameCallableUI",                   <--Unable to Remove
                #"Microsoft.Services.Store.Engagement",            <--Unable to Remove
                #"Microsoft.Advertising.Xaml",                     <--Unable to Remove
                #"Microsoft.Advertising.Xaml",                     <--Unable to Remove
                #"Windows.CBSPreview",                             <--Unable to Remove
                "Microsoft.BingNews",
                "46928bounde.EclipseManager",
                "ActiproSoftwareLLC.562882FEEB491",
                "Microsoft.Office.Sway",
                "Microsoft.NetworkSpeedTest",
                "AdobeSystemsIncorporated.AdobePhotoshopExpress",
                "Microsoft.BingTranslator",
                "D5EA27B7.Duolingo-LearnLanguagesforFree",
                "Microsoft.RemoteDesktop"
                #"Microsoft.Windows.SecHealthUI",                  <--Unable to Remove
                #"InputApp"                                        <--Unable to Remove                                       <--Unable to Remove            

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
$DateTime = Get-Date -format g
$logpathappx = "C:\admincfg\UninstallAppXPackages.log"
$logpathappXpro = "C:\admincfg\UninstallAppxProvpackages.log"

# 1709 AppXProvisionedPackage List
# Commended out AppxProvisioned packages which you may want to keep

$AppList =     #"Microsoft.BingWeather",
                "Microsoft.DesktopAppInstaller",
                "Microsoft.GetHelp",
                "Microsoft.Getstarted",
                "Microsoft.Messaging", 
                "Microsoft.Microsoft3DViewer",
                "Microsoft.MicrosoftOfficeHub",
                "Microsoft.MicrosoftSolitaireCollection",
               #"Microsoft.MicrosoftStickyNotes",
               #"Microsoft.MSPaint",
               #"Microsoft.Office.OneNote",
                "Microsoft.OneConnect",
                "Microsoft.People",
               #"Microsoft.Print3D",
                "Microsoft.SkypeApp",
                "Microsoft.StorePurchaseApp",
                "Microsoft.Wallet",
               #"Microsoft.Windows.Photos",
               #"Microsoft.WindowsAlarms",
               #"Microsoft.WindowsCalculator",
               #"Microsoft.WindowsCamera",
                "microsoft.windowscommunicationsapps",
                "Microsoft.WindowsFeedbackHub",
               #"Microsoft.WindowsMaps",
               #"Microsoft.WindowsSoundRecorder",
               #"Microsoft.WindowsStore",
                "Microsoft.Xbox.TCUI",
                "Microsoft.XboxApp",
                "Microsoft.XboxGameOverlay",
                "Microsoft.XboxIdentityProvider",
                "Microsoft.XboxSpeechToTextOverlay",
                "Microsoft.ZuneMusic",
                "Microsoft.ZuneVideo",
                #AppXpackages
                #"Microsoft.Windows.CloudExperienceHost",          <--Unable to Remove
                #"Microsoft.Windows.ContentDeliveryManager",       <--Unable to Remove
                #"Microsoft.Windows.HolographicFirstRun",          <--Unable to Remove
                #"Microsoft.Windows.ParentalControls",             <--Unable to Remove
                #"Microsoft.Windows.PeopleExperienceHost",         <--Unable to Remove
                #"Microsoft.XboxGameCallableUI",                   <--Unable to Remove
                #"Microsoft.Services.Store.Engagement",            <--Unable to Remove
                #"Microsoft.Advertising.Xaml",                     <--Unable to Remove
                #"Microsoft.Advertising.Xaml",                     <--Unable to Remove
                #"Windows.CBSPreview",                             <--Unable to Remove
                "Microsoft.BingNews",
                "46928bounde.EclipseManager",
                "ActiproSoftwareLLC.562882FEEB491",
                "Microsoft.Office.Sway",
                "Microsoft.NetworkSpeedTest",
                "AdobeSystemsIncorporated.AdobePhotoshopExpress",
                "Microsoft.BingTranslator",
                "D5EA27B7.Duolingo-LearnLanguagesforFree",
                "Microsoft.RemoteDesktop"
                #"Microsoft.Windows.SecHealthUI",                  <--Unable to Remove
                #"InputApp"                                        <--Unable to Remove
        
 
ForEach ($App in $AppList)
{
$PackageFullName = (Get-AppxPackage -AllUsers | Where-Object -property Name -eq $App) | format-table -hidetableheaders PackageFullName | Out-string
$PackageFullName = $PackageFullName.Trim()
$ProPackageFullName = (Get-AppxProvisionedPackage -online | Where-Object -property displayname -eq $App)| format-table -hidetableheaders packagename | Out-string
$ProPackageFullName = $ProPackageFullName.Trim()
write-host $PackageFullName
Write-Host $ProPackageFullName

if ($PackageFullName.Trim())
{
$DateTime = Get-Date -format g

Write-Host "Removing Package: $PackageFullName"
"$DateTime Removing Package: $PackageFullName" |out-file $logpathappx -append

Try {
# 1607 & 1703 Doesnt support -Allusers 
remove-AppxPackage -AllUsers -package $PackageFullName.Trim()
#(Get-AppxPackage -AllUsers | Where-Object -property Name -eq $PackageFullName.Trim()) | remove-AppxPackage -AllUsers
} catch {"Unable to find $PackageFullName"}
}
else
{
$DateTime = Get-Date -format g
Write-Host "Unable to find package: $App"
"$DateTime Unable to find package: $App" | out-file $logpathappx -append
}

if ($ProPackageFullName.Trim())
{
$DateTime = Get-Date -format g

Write-Host "Removing Provisioned Package: $ProPackageFullName"
"$DateTime Removing Provisioned Package: $ProPackageFullName" | out-file $logpathappxpro -append
Try {
Remove-AppxProvisionedPackage -online -packagename $ProPackageFullName.Trim()
} catch {"Unable to find $ProPackageFullName"}
}
else
{
$DateTime = Get-Date -format g
Write-Host "Unable to find provisioned package: $App" 
 "$DateTime Unable to find provisioned package: $App" | out-file $logpathappxpro -append
}
}
}
}

#End of block
}}
Enterpriseification1709 -output C:\AdminCfg