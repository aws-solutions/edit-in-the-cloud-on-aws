# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    #[string]$Source = 'https://d1uj6qtbmh3dt5.cloudfront.net/nice-dcv-server-x64-Release.msi',
    # Locking to 2021.3 to workaround permissions requirements for session sharing. 
    [string]$Source = 'https://d1uj6qtbmh3dt5.cloudfront.net/2021.3/Servers/nice-dcv-server-x64-Release-2021.3-11591.msi',
    [Parameter(Mandatory=$false)]
    [string]$Destination = 'C:\cfn\downloads\nice-dcv-server-x64-Release.msi'
)

try {
    $ErrorActionPreference = "Stop"

    $parentDir = Split-Path $Destination -Parent
    if (-not (Test-Path $parentDir)) {
        New-Item -Path $parentDir -ItemType directory -Force | Out-Null
    }

    Write-Host "Trying to download NiceDCV from $Source to $Destination"
    $tries = 5
    while ($tries -ge 1) {
        try {
            (New-Object System.Net.WebClient).DownloadFile($Source,$Destination)
            break
        }
        catch {
            $tries--
            Write-Host "Exception:"
            Write-Host "$_"
            if ($tries -lt 1) {
                throw $_
            }
            else {
                Write-Host "Failed download. Retrying again in 5 seconds"
                Start-Sleep 5
            }
        }
    }

    # Add a registry key to enable the QUIC (UDP) protocol in NiceDCV
    New-PSDrive -PSProvider Registry -Name HKU -Root HKEY_USERS
    New-Item -Path HKU:\S-1-5-18\Software\GSettings\com\nicesoftware\dcv\ -Name connectivity -Force
    New-ItemProperty -Path HKU:\S-1-5-18\Software\GSettings\com\nicesoftware\dcv\connectivity\ -Name enable-quic-frontend -Value 1

    if ([System.IO.Path]::GetExtension($Destination) -eq '.msi') {
       Write-Host "Start install of NiceDCV ..."
       # AUTOMATIC_SESSION_OWNER variable changes the default owner from SYSTEM to the local administrator
       # '/norestart' - to prevent reboot
       # 
       Start-Process msiexec.exe -ArgumentList "/I $Destination", 'AUTOMATIC_SESSION_OWNER=Administrator', '/quiet','/norestart', '/l*v dcv_install_msi.log'  -Wait
    } else {
        throw "Problem installing NiceDCV, not .msi extension"
    }
    Write-Host "Install NiceDCV complete"
}
catch {
    Write-Host "catch: $_"
    $_ | Write-AWSQuickStartException
}
