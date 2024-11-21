# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.4.2] - 2024-11-21

### Changed
  		  
- Security updates for npm packages

## [2.4.1] - 2023-11-02

### Changed

- Updated libraries for security patching
- Added solution-manifest.yaml file

## [2.4.0] - 2023-07-25

### Added

- Added ability to opt in or out of anonymized data collection when solution is deployed
- Added App Registry to this solution
- Updated solution to Node.js 18
- Note this update is not backward compatible and a new CloudFormation template must be launched. 

## [2.3.2] - 2022-04-20

### Changed

- Update the latest GRID /NVIDIA driver location to C:\Windows\System32\DriverStore\FileRepository\nvgrid*\ instead of  C:\Program Files\NVIDIA Corporation\NVSMI

## [2.3.1] - 2022-11-03

### Added

- Added -region us-east-1 argument to s3 download cmd for GPU Drivers

## [2.3.0] - 2022-06-09

### Changed

- Update the Domain Join process to use Systems Manager Document rather than powershell [Github Issue #7]

## [2.2.0] - 2022-03-16

### Changed

- Update NICE DCV to latest release (2022.0)
- Reinstate Teradici CAS
- Update install process for Teradici CAS to request user provide download token from Teradici portal <https://docs.teradici.com/find/product/cloud-access-software>

## [2.1.1] - 2022-03-07

### Changed

- Set NICE DCV as the default remote display protocol
- Teradici CAS as a remote display protocol option has been temporarily disabled in this release while we address a problem with deployment.
- Passed correct VPC CIDR range to AD template when user customizes this value
- Removed HostSG security group from FSx for Windows ENI
- Updated access rules on security group attached to FSx for Windows to allow access only from Domain Members
- Added Workstation to Domain Members security group
- Removal of commented code and minor cleanups in top level template
- NICE DCV set to use 2021.3 release

## [2.1.0] - 2021-01-12

### Changed

- Updated FSxDNSName Lambda runtime to python3.9
- Restructured cfn-init configsets to create steps for the Remote Display Protocol installation

### Added

- Added support for NICE DCV as a Remote Display Protocol. Default set to Teradici CAS
- Added powershell script to install NICE DCV from latest release (if selected)
- Added support for NICE DCV TCP and UDP protocol to host security group (if selected)
- Added permission to obtain NICE DCV license via s3:GetObject permissions in IAM Role (if selected)

## [2.0.0] - 2021-08-05

### Changed

- Updated user agent string to have a dynamic version number passed in from build script
- Deleted unused fgw-fileshare.py file
- Removed section from the build script that packaged fgw-fileshare.py
- Removed year from copyright notices

### Added

- Added new parameter for selecting which version of AWS managed AD to provision, default set to standard
- Added a .viperlightrc file to assist automated code scanning
- Added metrics disclosure to README

## [1.0.1] - 2021-05-27

### Changed

- Corrected Solution Builder ID

## [1.0.0] - 2021-05-20

### Added

- Initial release
