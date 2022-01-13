# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.1.0] - 2021-01-12

### Changed

- Updated FSxDNSName Lambda runtime to python3.9
- Restructured cfn-init configsets to create steps for the Remote Display Protocol installation

### Added

- Added support for NICE DCV as a Remote Display Protocol. Default set to Teradici CAS. 
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
