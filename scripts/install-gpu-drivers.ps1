[CmdletBinding()]
Param(
    [Parameter(Mandatory=$false)]
    [string]$GpuDriverBucket = 'ec2-windows-nvidia-drivers',
    [Parameter(Mandatory=$false)]
    [string]$GpuDriverBucketPrefix = '/latest',
    [Parameter(Mandatory=$false)]
    [string]$DownloadDir = 'c:\cfn\downloads',
    [Parameter(Mandatory=$false)]
    [string]$UnzipDir = 'c:\cfn\downloads\gpu-drivers'
)


# AWS instructions for GPU drivers
#
# GpuDriverBucket is set from location specified in docs below
#
# http://docs.aws.amazon.com/AWSEC2/latest/WindowsGuide/accelerated-computing-instances.html

#
# $Bucket = name of S3 bucket holding driver files for multiple OSes and the License Agreement to be signed
# $OsMatchStr = 'win10' for windows 10 ... this is a substring that will be matched in the s3 object key
#               (equal to filenames for the gpu driver
#
# returns the full pathname of the driver filename
#
function downloadGpuDrivers($Bucket, $BucketPrefix, $OsMatchStr, $DownloadDir) {
    Write-Host "Download from $Bucket and match on $OsMatchStr"
    $DriverFilename = '<not found>'
    # https://docs.aws.amazon.com/powershell/latest/reference/TOC.html
    $Objects = Get-S3Object -BucketName $Bucket -Prefix $BucketPrefix
    foreach ($Object in $Objects) {
        Write-Host $Object.Key
        $FileName = $Object.Key
        # we want the gpu driver for the required OS as well as the license file
        # from the S3 bucket
        Write-Host "match os str: ($Filename -match $OsMatchStr)"
        Write-Host $Object.Size
        if ($FileName -ne '' -and $Object.Size -ne 0 -and
           ($FileName -match $OsMatchStr -or $FileName -match 'LicenseAgreement')) {
		    $FullFilePath = Join-Path $DownloadDir $FileName
	        Copy-S3Object -BucketName $Bucket -Key $Object.Key -LocalFile $FullFilePath
            Write-Host "Copying file $FileName"
            Write-Host "LocalFileName: $LocalFileName"
            Write-Host "FullFilePath: $FullFilePath"
             if ($FileName -match $OsMatchStr) {
                # filename denotes the os we are looking for
                $DriverFilename = $FullFilePath
                Write-Host "Set DriverFilename: $DriverFilename"
            }
        }
    }

    return
}


# $Filename = full path to gpu drivers
# $Destination = directory where we will unzip the drivers
#
# gpu drivers will be unzipped into
function unzipGpuDrivers($Filename, $Destination) {
    Write-Host "Unzip GPU Drivers"
    $parentDir = Split-Path $Destination -Parent
    if (-not (Test-Path $parentDir)) {
        New-Item -Path $parentDir -ItemType directory -Force | Out-Null
        Write-Host "creating new directory"
    }

    Write-Host "Extract GPU drivers ... from $Filename"
    # first extract the setup.exe so we can pass the -noreboot = noreboot and -s = silent cmd line params
    # self extracting installer only excepts /s
    #
    # x = preserve dir structure
    # -aoa = overwrite
    # -o is output dir
    Start-Process -Verbose -FilePath "c:\Program Files\7-Zip\7z.exe" -ArgumentList 'x',$Filename,'-aoa',"-o$($Destination)" -NoNewWindow -Wait

}


function InstallGpuDrivers($SetupDir) {
    Write-Host "Install GPU drivers ... run setup.exe"
    # -noreboot = no reboot
    # -s = silent install, don't pop up a window for input
    # Start-Process -FilePath Join-Path $SetupDir "setup.exe" -ArgumentList '-s' -Wait

    # using a ProcessStartInfo object is masking the exit 1
    #
    $pinfo = New-Object System.Diagnostics.ProcessStartInfo
    $pinfo.FileName = Join-Path $SetupDir "setup.exe"
    $pinfo.RedirectStandardError = $true
    $pinfo.RedirectStandardOutput = $true
    $pinfo.UseShellExecute = $false
    $pinfo.Arguments = '-s'
    $p = New-Object System.Diagnostics.Process
    $p.StartInfo = $pinfo
    $p.Start()
    $p.WaitForExit()
    $stdout = $p.StandardOutput.ReadToEnd()
    $stderr = $p.StandardError.ReadToEnd()
    Write-Host "gpu driver install process stdout: $stdout"
    Write-Host "gpu driver install stderr: $stderr"
    Write-Host "gpu driver install exit code:"
    $p.ExitCode | Write-Host

    Write-Host "complete: install GPU drivers"
}

#
# Optimize GPU settings
# https://docs.aws.amazon.com/AWSEC2/latest/WindowsGuide/optimize_gpu.html
function OptimizeGpu() {
    # this is for G4 only
    Set-Location "C:\Program Files\NVIDIA Corporation\NVSMI"
    .\nvidia-smi --auto-boost-default=0
    .\nvidia-smi -ac "5001,1590"
}

#
# main
#
# http://nvidia.custhelp.com/app/answers/detail/a_id/2985/~/how-can-i-perform-a-silent-install-of-the-gpu-driver%3F
# https://devtalk.nvidia.com/default/topic/830929/quadro-348-07-driver-silent-installation-unable-to-generate-setup-iss-response-file/
#

try {
    $ErrorActionPreference = "Stop"

    $GpuDriverFilename = downloadGpuDrivers -Bucket $GpuDriverBucket -BucketPrefix $GpuDriverBucketPrefix -OsMatchStr 'win10' -DownloadDir $DownloadDir
    Write-Host "filename = '$GpuDriverFilename'"
    unzipGpuDrivers -Filename $GpuDriverFilename -Destination $UnzipDir
    InstallGpuDrivers -SetupDir $UnzipDir
    OptimizeGpu
}
catch {
    Write-Host "catch: $_"
    $_ | Write-AWSQuickStartException
}
 