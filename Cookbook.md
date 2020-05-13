# Overview

Cookbook to reflect usage of the Cloudformation templates to suit different use cases.

# Use Cases
In general, there are different use cases under which these templates can be used. A few of these are supported and detailed below:

1. Complete Cloud Video Editing Env with FSx
	* This includes VPC, AD, EC2 cloud edit host with FSx filesystem
1. Complete Cloud Video Editing Env with Storage Gateway
	* This includes VPC, AD, EC2 cloud edit host with FileGateway
1. Additional Edit Host(s)
	* Allows for creation of an additional edit host (in the same AD, VPC)
1. Integrate with existing env. - Edit host + FSx
	* Uses the existing AD, VPC and creates a new EC2 Edit Host and FSx filesystem
1. Integrate with existing env. - Edit host + SGW
	* Uses the existing AD, VPC and creates a new EC2 Edit Host and Storage Gateway (File Gateway type) host

## Complete Cloud Video Editing Env with FSx

### Purpose
This is essentially a complete Cloud Editing env. Will create:

- A stand-alone VPC across 2 AZs
- A Managed AD domain with an Admin user account
- A single edit host (G4 series) with Teradici installed and NVIDIA Grid drivers configured
- A FSx for Windows filesystem for use in the edit host

### Use Existing Templates
* Launch a region-specific stack.
	* [Launch us-east-1 Stack](https://us-east-1.console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/create/review?templateURL=https://cloud-video-editing-us-east-1.s3.amazonaws.com/cfn-repo/templates/cloud-video-editing-master-with-FSX.yaml)
	* [Launch us-west-2 Stack](https://us-west-2.console.aws.amazon.com/cloudformation/home?region=us-west-2#/stacks/create/review?templateURL=https://cloud-video-editing-us-west-2.s3-us-west-2.amazonaws.com/cfn-repo/templates/cloud-video-editing-master-with-FSX.yaml)
	* Consult the [CloudFormation Parameters README](Cloudformation_Parameters.md) for more details on the parameters.


### Build

1. Define Make variables for your setup. Run `./configure` accordingly.

1. Edit the parameter file `ci/cloud-video-editing-master-with-FSX.json` and change the parameters as needed. More details on parameters can be found [here](Cloudformation_Parameters.md) .

1. Run the script for creating the cloudformation stack

```
make create-stack
```

## Complete Cloud Video Editing Env with Storage Gateway

### Purpose
This is essentially a complete Cloud Editing env. Will create:

- A stand-alone VPC across 2 AZs
- A Managed AD domain with an Admin user account
- A single edit host (G4 series) with Teradici installed and NVIDIA Grid drivers configured
- A Storage Gateway host (File Gateway type) for use in the edit host

### Use Existing Templates
* Launch a region-specific stack.
	* [Launch us-east-1 Stack](https://us-east-1.console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/create/review?templateURL=https://cloud-video-editing-us-east-1.s3.amazonaws.com/cfn-repo/templates/cloud-video-editing-master-with-SGW.yaml)
	* [Launch us-west-2 Stack](https://us-west-2.console.aws.amazon.com/cloudformation/home?region=us-west-2#/stacks/create/review?templateURL=https://cloud-video-editing-us-west-2.s3-us-west-2.amazonaws.com/cfn-repo/templates/cloud-video-editing-master-with-SGW.yaml)
	* Consult the [CloudFormation Parameters README](Cloudformation_Parameters.md) for more details on the parameters.

### Build

1. Define Make variables for your setup. Run `./configure` accordingly.

1. Edit the parameter file `ci/cloud-video-editing-master-with-SGW.json` and change the parameters as needed. More details on parameters can be found [here](Cloudformation_Parameters.md) .

1. Run the script for creating the cloudformation stack

```
make create-stack
```

## Additional Edit Host

### Purpose
This assumes a Cloud Editing Stack has already been created and is available for use. Assumes an existing VPC and AD Domain. Creates:

* Single EC2-based edit host 
	* within the same VPC, and,
	* member of the AD domain

### Use Existing Templates
* Launch a region-specific stack.
	* [Launch us-east-1 Stack](https://us-east-1.console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/create/review?templateURL=https://cloud-video-editing-us-east-1.s3.amazonaws.com/cfn-repo/templates/cloud-video-editing-edit-host.yaml)
	* [Launch us-west-2 Stack](https://us-west-2.console.aws.amazon.com/cloudformation/home?region=us-west-2#/stacks/create/review?templateURL=https://cloud-video-editing-us-west-2.s3-us-west-2.amazonaws.com/cfn-repo/templates/cloud-video-editing-edit-host.yaml)
	* Consult the [CloudFormation Parameters README](Cloudformation_Parameters.md) for more details on the parameters.

### Build

1. Define Make variables for your setup. Run `./configure` accordingly.

1. Update the edit host parameter file `ci/cloud-video-editing-edit-host.json` with relevant parameters from the existing stack. More details on parameters can be found [here](Cloudformation_Parameters.md) .

1. Run the script for creating a single additional host

```
make create-stack
```

## Integrate with existing env. - Edit host + FSx

### Purpose
This assumes an existing VPC and AD Domain. Creates:

* Single EC2-based edit host 
	* within the same VPC, and,
	* member of the AD domain

* FSX based file system
	* within the same VPC, and,
	* member of the AD domain
	* Each individual edit host will need to map the network drive individually

### Use Existing Templates
* Launch a region-specific stack.
	* [Launch us-east-1 Stack](https://us-east-1.console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/create/review?templateURL=https://cloud-video-editing-us-east-1.s3.amazonaws.com/cfn-repo/templates/cloud-video-editing-FSX-with-existing-AD.yaml)
	* [Launch us-west-2 Stack](https://us-west-2.console.aws.amazon.com/cloudformation/home?region=us-west-2#/stacks/create/review?templateURL=https://cloud-video-editing-us-west-2.s3-us-west-2.amazonaws.com/cfn-repo/templates/cloud-video-editing-FSX-with-existing-AD.yaml)
	* Consult the [CloudFormation Parameters README](Cloudformation_Parameters.md) for more details on the parameters.

### Build

1. Define Make variables for your setup. Run `./configure` accordingly.

1. Edit the edit host parameter file `ci/cloud-video-editing-FSX-with-existing-AD.json`. More details on parameters can be found [here](Cloudformation_Parameters.md) .

1. Run the script for creating a single additional host + FSX filesystem:

```
make create-stack
```

## Integrate with existing env. - Edit host + SGW

### Purpose
This assumes an existing VPC and AD Domain. Creates:

* Single EC2-based edit host 
	* within the same VPC, and,
	* member of the AD domain

* SGW based file system
	* within the same VPC, and,
	* member of the AD domain
	* Each individual edit host will need to map the network drive individually

### Use Existing Templates
* Launch a region-specific stack.
	* [Launch us-east-1 Stack](https://us-east-1.console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/create/review?templateURL=https://cloud-video-editing-us-east-1.s3.amazonaws.com/cfn-repo/templates/cloud-video-editing-SGW-with-existing-AD.yaml)
	* [Launch us-west-2 Stack](https://us-west-2.console.aws.amazon.com/cloudformation/home?region=us-west-2#/stacks/create/review?templateURL=https://cloud-video-editing-us-west-2.s3-us-west-2.amazonaws.com/cfn-repo/templates/cloud-video-editing-SGW-with-existing-AD.yaml)
	* Consult the [CloudFormation Parameters README](Cloudformation_Parameters.md) for more details on the parameters.

### Build

1. Define Make variables for your setup. Run `./configure` accordingly.

1. Edit the edit host parameter file `ci/cloud-video-editing-SGW-with-existing-AD.json`. More details on parameters can be found [here](Cloudformation_Parameters.md) .

1. Run the script for creating a single additional host + Storage Gateway:

```
make create-stack
```

## Post Creation on Edit Host(s)

1. Connect using RDP and enter the Teradici license key using the system tray

1. Login using the PCOIP client on your desktop with Domain Admin Password 

1. On login, the network drive to the underlying storage system selected will be mapped automatically.

