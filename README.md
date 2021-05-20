# AWS Edit in the Cloud

This step-by-step guide details how to deploy an edit host, storage, and connectivity on AWS. This template allows users to build additional features, and add functionality, into an Amazon Elastic Compute Cloud (Amazon EC2) deployment. By incorporating Amazon FSx for Windows File Server, you can utilize a central repository for your media assets while providing an easy connection to your EC2 instance. The template also includes AWS Directory Services in conjunction with Teradici for Federated Login to allow for seamless editorial experience. Once you are logged into AWS management console, use this AWS CloudFormation deployment template.

## Building distributable for customization

* Configure the bucket name of your target Amazon S3 distribution bucket

```sh
export SOLUTION_NAME=aws-edit-in-the-cloud
export VERSION=v1.0.0
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

* Deploy the distributable to an Amazon S3 bucket in your account. _Note:_ you must have the AWS Command Line Interface installed.

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

## File Structure

```text
|-deployment/
  |-build-s3-dist.sh             [ shell script for packaging distribution assets ]
  |-solution.yaml                [ solution CloudFormation deployment template ]
|-source/                        [ source code of helper files]
```

***

Copyright 2019-2021 Amazon.com, Inc. or its affiliates. All Rights Reserved.

Licensed under the Apache License Version 2.0 (the "License"). You may not use this file except in compliance with the License. A copy of the License is located at

<http://www.apache.org/licenses/>

or in the "license" file accompanying this file. This file is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, express or implied. See the License for the specific language governing permissions and limitations under the License.
