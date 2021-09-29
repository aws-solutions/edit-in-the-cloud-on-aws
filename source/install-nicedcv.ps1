# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$Source = 'https://d1uj6qtbmh3dt5.cloudfront.net/2021.2/Servers/nice-dcv-server-x64-Release-2021.2-11135.msi',
    [Parameter(Mandatory=$false)]
    [string]$Destination = 'C:\cfn\downloads\nice-dcv-server-x64-Release-2021.2-11135.msi'
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

    if ([System.IO.Path]::GetExtension($Destination) -eq '.msi') {
       Write-Host "Start install of NiceDCV ..."
       # '/NoPostReboot' - to prevent reboot
       #
       Start-Process msiexec.exe -ArgumentList "/I $Destination", '/quiet','/norestart', '/l*v dcv_install_msi.log'  -Wait
    } else {
        throw "Problem installing NiceDCV, not .msi extension"
    }
    Write-Host "Install NiceDCV complete"
}
catch {
    Write-Host "catch: $_"
    $_ | Write-AWSQuickStartException
}
