[cmdletbinding()]
Param()


try {
    $ErrorActionPreference = "Stop"

    #
    # Install packages
    #
    Write-Verbose "Install Chocolatey"
    $url = 'https://chocolatey.org/install.ps1'
    Invoke-Expression ((new-object net.webclient).DownloadString($url))

    Write-Host "aws: Install 7zip"
    Write-Host "Install 7zip"
    choco install --limit-output -y 7zip

    Write-Host "Install awscli"
    choco install --limit-output -y awscli

    Write-Host "Install Chrome"
    choco install --limit-output -y googlechrome

    Write-Host "choco installs complete"
}
catch {
    Write-Host "catch: $_"
    $_ | Write-AWSQuickStartException
}




