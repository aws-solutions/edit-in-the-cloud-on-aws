# AWS Edit in the Cloud

This step-by-step guide details how to deploy an edit host, storage, and connectivity on AWS. This template allows users to build additional features, and add functionality, into an Amazon Elastic Compute Cloud (Amazon EC2) deployment. By incorporating Amazon FSx for Windows File Server, you can utilize a central repository for your media assets while providing an easy connection to your EC2 instance. The template also includes AWS Directory Services for federated login to allow for seamless editorial experience. Once you are logged into AWS Management Console, use this AWS CloudFormation deployment template.

When deploying this solution, you are able to select from either Teradici CAS (https://www.teradici.com/products/CAS-cloud-access-software) or NICE DCV (https://aws.amazon.com/hpc/dcv/) as the Remote Display Protocol installed on the EC2 based Edit Workstation. 

## Teradici CAS Installation Notes

In order to download the Teradici CAS Graphics Agent for Windows, customers are issued with a unique download token by Teradici. This solution prompts for this token as a parameter of the CloudFormation template used to deploy from. 

To obtain the download token from Teradici:

1. Open https://docs.teradici.com/find/product/cloud-access-software
2. Click on the download link for the Teradici Graphics Agent for Windows.
3. You will be prompted to sign in (if not already signed in).
4. After signing in, click on the "Downloads and scripts" link.
5. You will be prompted to agree to an EULA. 
6. After reviewing and agreeing to the EULA, click on the "Download using a script" link.
7. Example download commands using cURL will be displayed. Each sample command contains a download URL which contains a 16-character token that immediately follows "https://dl.teradici.com/", for example "https://dl.teradici.com/1234567890abcdef/pcoip-agent/...." where "1234567890abcdef" is the token. Copy this token, it is unique to your Teradici login. 
8. Use this token in the TeradiciDownloadToken parameter required by the CloudFormation template in this solution. 

Teradici client software can also be obtained from the same site. 

Teradici CAS installations require a subscription which can be obtained from Teradici. Please see the AWS Edit in the Cloud Implementation Guide (https://docs.aws.amazon.com/solutions/latest/aws-edit-in-the-cloud/welcome.html) for details on obtaining and applying a license for this sofware after the solution is deployed. 

## NICE DCV Installation Notes

You do not need a license server to install and use NICE DCV on an EC2 instance. This solution sets up the necessary access to a specific S3 bucket which is used to obtain a license for NICE DCV when running on EC2. 

NICE DCV clients for Windows, MacOS and Linux can be downloaded from https://download.nice-dcv.com/ 

## Development Notes

### Building distributable for customization

* Configure the bucket name of your target Amazon S3 distribution bucket

```sh
export SOLUTION_NAME=aws-edit-in-the-cloud
export VERSION=v1.0.1
export BUCKET_PREFIX=my_s3_bucket # change this variable to the basename of your S3 bucket
export REGION_TO_TEST=us-west-2 # change this variable to the region of your S3 bucket
export TEMPLATE_OUTPUT_BUCKET=$BUCKET_PREFIX
export DIST_OUTPUT_BUCKET=$BUCKET_PREFIX
export BUILD_OUTPUT_BUCKET=$DIST_OUTPUT_BUCKET-$REGION_TO_TEST
export CFN_TEMPLATE="aws-edit-in-the-cloud.template"
```

_Note:_ You would have to create an S3 bucket with the prefix 'my_s3_bucket-<aws_region>'; aws_region is where you are testing the customized solution. Also, the assets in bucket should be publicly accessible.

* Now build the distributable:

```sh
cd deployment
chmod +x ./build-s3-dist.sh
./build-s3-dist.sh $DIST_OUTPUT_BUCKET $SOLUTION_NAME $VERSION $TEMPLATE_OUTPUT_BUCKET
```

> **Notes**: The _build-s3-dist_ script expects two S3 buckets as input parameters: one for the global assets, and one for regional assets. 

Ensure that you are owner of the AWS S3 buckets passed to the build-s3-dist.sh script:

```
aws s3api head-bucket --bucket $TEMPLATE_OUTPUT_BUCKET --expected-bucket-owner YOUR-AWS-ACCOUNT-NUMBER
aws s3api head-bucket --bucket $BUILD_OUTPUT_BUCKET --expected-bucket-owner YOUR-AWS-ACCOUNT-NUMBER
```

* Deploy the distributable to an Amazon S3 bucket in your account. 

```sh
aws s3 cp global-s3-assets/  s3://$TEMPLATE_OUTPUT_BUCKET/$SOLUTION_NAME/$VERSION/ --recursive --acl bucket-owner-full-control
aws s3 cp regional-s3-assets/ s3://$BUILD_OUTPUT_BUCKET/$SOLUTION_NAME/$VERSION/ --recursive --acl bucket-owner-full-control
```

* Get the link of the solution template uploaded to your Amazon S3 bucket.

```sh
echo "https://s3.amazonaws.com/$TEMPLATE_OUTPUT_BUCKET/$SOLUTION_NAME/$VERSION/$CFN_TEMPLATE"
```

* Deploy the solution to your account by launching a new AWS CloudFormation stack using the link of the solution template in Amazon S3.

***

### File Structure

```text
|-deployment/
  |-build-s3-dist.sh             [ shell script for packaging distribution assets ]
  |-solution.yaml                [ solution CloudFormation deployment template ]
|-source/                        [ source code of helper files]
```

***

This solution collects anonymous operational metrics to help AWS improve the
quality of features of the solution. For more information, including how to disable
this capability, please see the [implementation guide](https://docs.aws.amazon.com/solutions/latest/aws-edit-in-the-cloud/collection-of-operational-metrics.html)

Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.

Licensed under the Apache License Version 2.0 (the "License"). You may not use this file except in compliance with the License. A copy of the License is located at

<http://www.apache.org/licenses/>

or in the "license" file accompanying this file. This file is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, express or implied. See the License for the specific language governing permissions and limitations under the License.
