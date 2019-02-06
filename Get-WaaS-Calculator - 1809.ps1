<#
Author: Michael A. Henderson
Date: Feb 5, 2019
Description: This script will download the "WaaS-Calculator- 1809 v1.2.pbix" Power BI dashboard and run it on a local device. 

#>

#Create Folder
New-Item -ItemType Directory -Force -Path "C:\WaaS-Calculator" -verbose

#Load Library TLS
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$url = "https://github.com/mihender50/LinkedIn-Content/raw/WaaS-Calculator/WaaS-Calculator-1809.zip"
$output = "C:\WaaS-Calculator\WaaS-Calculator-1809.zip"
$start_time = Get-Date

#Invoke WebRequest
Invoke-WebRequest -Uri $url -OutFile $output -verbose
Write-Output "Time taken: $((Get-Date).Subtract($start_time).Seconds) second(s)"

#Load Library for decompressing files
Add-Type -assembly "system.io.compression.filesystem" -verbose

#Set Variables
$BackUpPath = "C:\WaaS-Calculator\WaaS-Calculator-1809.zip"
$destination = "C:\WaaS-Calculator"

#Decompress File and define a destination location
[io.compression.zipfile]::ExtractToDirectory($BackUpPath, $destination)

#Define PowerBI file
$PBIFile = "WaaS-Calculator- 1809 v1.2.pbix"

# Open PowerBI Load .pbix file
Start-Process "C:\WaaS-Calculator\WaaS-Calculator-1809\$PBIFile" -WindowStyle normal -verbose

