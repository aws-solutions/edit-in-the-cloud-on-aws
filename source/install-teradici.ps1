# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$Source = 'https://downloads.teradici.com/win/stable/PCoIP_agent_release_installer_graphics.exe',
    [Parameter(Mandatory=$false)]
    [string]$Destination = 'C:\cfn\downloads\PCoIP_agent_release_installer_graphics.exe'
)

try {
    $ErrorActionPreference = "Stop"

    $parentDir = Split-Path $Destination -Parent
    if (-not (Test-Path $parentDir)) {
        New-Item -Path $parentDir -ItemType directory -Force | Out-Null
    }

    Write-Host "Trying to download Teradici from $Source to $Destination"
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

    if ([System.IO.Path]::GetExtension($Destination) -eq '.exe') {
       Write-Host "Start install of Teradici ..."
       # '/NoPostReboot' - to prevent reboot
       #
       Start-Process -FilePath $Destination -ArgumentList '/S','/nodeskside', '/NoPostReboot'  -Wait
    } else {
        throw "Problem installing Teradici, not .exe extension"
    }
    Write-Host "Install Teradici complete"
}
catch {
    Write-Host "catch: $_"
    $_ | Write-AWSQuickStartException
}
