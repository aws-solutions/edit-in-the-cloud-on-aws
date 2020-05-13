# Overview

This will describe the various parameters used in the Cloudformation templates. Please use them accordingly.

## Important Parameters

| Parameter Name  | Parameter Description  | Can be used in files |
|:-------------:|:---------------:|:------------- |
| `AssetS3BucketName` | Storage Gateway file share bucket name can include numbers, lowercase letters, and hyphens (-). It cannot start or end with a hyphen (-). | `cloud-video-editing-master-with-SGW.json` `cloud-video-editing-SGW-with-existing-AD.yaml` |
| `AvailabilityZones` | List of Availability Zones to use for the subnets in the VPC. Note: The logical order is preserved and only 2 AZs are used for this deployment. | `cloud-video-editing-master-with-FSX.json` `cloud-video-editing-master-with-SGW.json` |
| `AZDeploymentMode` | Specifies the FSx for Windows file system deployment type | `cloud-video-editing-master-with-FSX.json` `cloud-video-editing-FSX-with-existing-AD.yaml` |
| `CloudFormationBucketName` | CloudFormation assets bucket name can include numbers, lowercase letters, uppercase letters, and hyphens (-). It cannot start or end with a hyphen (-). | `cloud-video-editing-master-with-FSX.json` `cloud-video-editing-master-with-SGW.json` `cloud-video-editing-FSX-with-existing-AD.yaml` `cloud-video-editing-SGW-with-existing-AD.yaml` `cloud-video-editing-edit-host.yaml` |
| `CloudFormationKeyPrefix` | CloudFormation assets key prefix can include numbers, lowercase letters, uppercase letters, hyphens (-), and forward slash (/). | `cloud-video-editing-master-with-FSX.json` `cloud-video-editing-master-with-SGW.json` `cloud-video-editing-FSX-with-existing-AD.yaml` `cloud-video-editing-SGW-with-existing-AD.yaml` `cloud-video-editing-edit-host.yaml` |
| `DirectoryId` | (AD) Directory ID (from existing AD)| `cloud-video-editing-FSX-with-existing-AD.yaml` |
| `DomainAdminUser` | User name for the account that will be added as Domain Administrator. This is separate from the default "Administrator" account | `cloud-video-editing-master-with-FSX.json` `cloud-video-editing-master-with-SGW.json` `cloud-video-editing-FSX-with-existing-AD.yaml` `cloud-video-editing-SGW-with-existing-AD.yaml` `cloud-video-editing-edit-host.yaml` |
| `DomainAdminPassword` | Password for the domain admin user. Must be at least 8 characters containing letters, numbers and symbols. | `cloud-video-editing-master-with-FSX.json` `cloud-video-editing-master-with-SGW.json` `cloud-video-editing-FSX-with-existing-AD.yaml` `cloud-video-editing-SGW-with-existing-AD.yaml` `cloud-video-editing-edit-host.yaml` |
| `DomainDNSName` | Fully qualified domain name (FQDN) of the forest root domain e.g. example.com | `cloud-video-editing-master-with-FSX.json` `cloud-video-editing-master-with-SGW.json` `cloud-video-editing-FSX-with-existing-AD.yaml` `cloud-video-editing-SGW-with-existing-AD.yaml` `cloud-video-editing-edit-host.yaml` |
| `DomainMemberSGID` | (ActiveDirectory) Domain Member Security Group ID | `cloud-video-editing-FSX-with-existing-AD.yaml` `cloud-video-editing-SGW-with-existing-AD.yaml` |
| `DomainNetBIOSName` | NetBIOS name of the domain (up to 15 characters) for users of earlier versions of Windows e.g. EXAMPLE | `cloud-video-editing-master-with-FSX.json` `cloud-video-editing-master-with-SGW.json` `cloud-video-editing-FSX-with-existing-AD.yaml` `cloud-video-editing-SGW-with-existing-AD.yaml` `cloud-video-editing-edit-host.yaml` |
| `EditHostAccessCIDR` | IP Addresses (CIDR block) to allow for remote ingress | `cloud-video-editing-master-with-FSX.json` `cloud-video-editing-master-with-SGW.json` `cloud-video-editing-FSX-with-existing-AD.yaml` `cloud-video-editing-SGW-with-existing-AD.yaml` |
| `EditHostInstanceType` | Amazon EC2 instance type for the Video Editing Servers | `cloud-video-editing-master-with-FSX.json` `cloud-video-editing-master-with-SGW.json` `cloud-video-editing-FSX-with-existing-AD.yaml` `cloud-video-editing-SGW-with-existing-AD.yaml` |
| `EnableFSXStack` | Enable the Creation of the FSX Stack | `cloud-video-editing-master-with-FSX.json` |
| `EnableSGWStack` | Enable the Creation of the SGW Stack | `cloud-video-editing-master-with-SGW.json` |
| `ExistingHostSecurityGroupID` | Host Access Security Group (from VPC) previously created | `cloud-video-editing-edit-host.yaml` |
| `FileSystemSize` | The storage capacity of the file system being created. 32 GiB - 65,536 GiB (64 TiB) | `cloud-video-editing-master-with-FSX.json` `cloud-video-editing-FSX-with-existing-AD.yaml` |
| `FSxNetworkFileShare` | Network Share Mapping for the FSx File System (from the FSx created earlier) | `cloud-video-editing-edit-host.yaml` |
| `FSxThroughput` | The throughput capacity of an Amazon FSx file system, measured in megabytes per second in powers of 2 (8, 16, 32, ... , 1024), with the recommended value based on the file system size: 8 for <800 GiB, 16 for <1600 GiB, ... 512 for <51200 GiB, 1024 for >=51200 GiB | `cloud-video-editing-master-with-FSX.json` `cloud-video-editing-FSX-with-existing-AD.yaml` |
| `HostSubnetId` | Primary Public Subnet (from existing VPC)| `cloud-video-editing-edit-host.yaml` |
| `InstanceType` | Amazon EC2 instance type for the Video Editing Server | `cloud-video-editing-edit-host.yaml` |
| `KeyPairName` | Public/private key pairs allow you to securely connect to your instance after it launches | `cloud-video-editing-master-with-FSX.json` `cloud-video-editing-master-with-SGW.json` `cloud-video-editing-FSX-with-existing-AD.yaml` `cloud-video-editing-SGW-with-existing-AD.yaml` `cloud-video-editing-edit-host.yaml` |
| `PrivateSubnet1AID` | Primary Private Subnet (from existing VPC)| `cloud-video-editing-FSX-with-existing-AD.yaml` `cloud-video-editing-SGW-with-existing-AD.yaml` |
| `PrivateSubnet2AID` | Secondary Private Subnet (from existing VPC)| `cloud-video-editing-FSX-with-existing-AD.yaml` |
| `Project` | Tag used for billing and resource groups | `cloud-video-editing-master-with-FSX.json` `cloud-video-editing-master-with-SGW.json` `cloud-video-editing-FSX-with-existing-AD.yaml` `cloud-video-editing-SGW-with-existing-AD.yaml` |
| `PublicSubnet1ID` | Primary Public Subnet (from existing VPC)| `cloud-video-editing-FSX-with-existing-AD.yaml` `cloud-video-editing-SGW-with-existing-AD.yaml` |
| `sgwCacheSize` | Cache for the Storage Gateway in (GiB), Minimum 150 GiB | `cloud-video-editing-master-with-SGW.json` `cloud-video-editing-SGW-with-existing-AD.yaml` |
| `sgwInstanceType` | EC2 instance type for the Storage Gateway usually m5.xlarge | `cloud-video-editing-master-with-SGW.json` `cloud-video-editing-SGW-with-existing-AD.yaml` |
| `SGWNetworkFileShare` | Network Share Mapping for the Storage Gateway (from the SGW created earlier) | `cloud-video-editing-edit-host.yaml` |
| `sgwProvisionedIOPS` | Disk cache IOPS range of 100 to 16000 | `cloud-video-editing-master-with-SGW.json` `cloud-video-editing-SGW-with-existing-AD.yaml` |
| `sgwVolumeType` | Choose gp2 (general purpose), io1 (provisioned IOPS), or st1 (throughput optimized HDD) | `cloud-video-editing-master-with-SGW.json` `cloud-video-editing-SGW-with-existing-AD.yaml` |
| `VPCID` | VPC ID (from existing VPC)| `cloud-video-editing-FSX-with-existing-AD.yaml` `cloud-video-editing-SGW-with-existing-AD.yaml` |

