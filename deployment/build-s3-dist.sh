#!/bin/bash
#
# This assumes all of the OS-level configuration has been completed and git repo has already been cloned
#
# This script should be run from the repo's deployment directory
# cd deployment
# ./build-s3-dist.sh source-bucket-base-name solution-name version-code
#
# Paramenters:
#  - source-bucket-base-name: Name for the S3 bucket location where the template will source the Lambda
#    code from. The template will append '-[region_name]' to this bucket name.
#    For example: ./build-s3-dist.sh solutions trademarked-solution-name v1.0.0 template-bucket-name
#    The template will then expect the source code to be located in the solutions-[region_name] bucket
#    The template-bucket-name is not region specific, and we will not append [region_name] to that bucket
#
#  - solution-name: name of the solution for consistency
#
#  - version-code: version of the package

# Check to see if input has been provided:
if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ] || [ -z "$4" ]; then
    echo "Please provide the base source bucket name, trademark approved solution name and version where the lambda code will eventually reside."
    echo "For example: ./build-s3-dist.sh solutions trademarked-solution-name v1.0.0 template-bucket-name"
    echo "The template will then expect the source code to be located in the solutions-[region_name] bucket"
    echo "The template-bucket-name is not region specific, and we will not append [region_name] to that bucket"
    exit 1
fi

# Debug 
DEBUG=true

# Get reference for all important folders
template_dir="$PWD"
template_dist_dir="$template_dir/global-s3-assets"
build_dist_dir="$template_dir/regional-s3-assets"
source_dir="$template_dir/../source"

echo "------------------------------------------------------------------------------"
echo "[Init] Clean old dist, node_modules and bower_components folders"
echo "------------------------------------------------------------------------------"
echo "rm -rf $template_dist_dir"
rm -rf $template_dist_dir
echo "mkdir -p $template_dist_dir"
mkdir -p $template_dist_dir
echo "rm -rf $build_dist_dir"
rm -rf $build_dist_dir
echo "mkdir -p $build_dist_dir"
mkdir -p $build_dist_dir

echo "------------------------------------------------------------------------------"
echo "[Packing] Templates"
echo "------------------------------------------------------------------------------"

echo "copy CFN templates scripts to $template_dist_dir"
find $template_dir -type f \( -iname \*.yaml -o -iname \*.template \) -exec cp "{}" $template_dist_dir \;

echo "find *.yaml and change extension to *.template in $template_dist_dir"
find $template_dist_dir -name "*.yaml" -exec sh -c 'mv "$1" "${1%.yaml}.template"' _ {} \;

echo "Doing sed commands on *.template with the following: "
replace1="s/__BUCKET_NAME__/$1/g"
echo $replace1
replace2="s/__SOLUTION_NAME__/$2/g"
echo $replace2
replace3="s/__VERSION__/$3/g"
echo $replace3
replace4="s/__TEMPLATE_BUCKET_NAME__/$4/g"
echo $replace4

# macOS workaround sed command
SED_CMD="sed -i"
if [[ "$OSTYPE" == "darwin"* ]]; then
    SED_CMD="sed -i.temp "
    echo "WARN macOS only: sed command is different: $SED_CMD"
fi

find $template_dist_dir -name "*.template" -exec $SED_CMD -e $replace1 -e $replace2 -e $replace3 -e $replace4 {} \;

# macOS workaround to delete temp files
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "WARN macOS only: deleting *.template.temp files"
    find $template_dist_dir -name "*.template.temp" -exec rm {} \;
fi


if [ "$DEBUG" = true ] ; then
    echo "DEBUG Below are changes made to templates: "
    find $template_dist_dir -name "*.template" -exec grep -E "$1|$2|$3|$4" {} +
    echo "DEBUG Below are changes that were missed: "
    find $template_dist_dir -name "*.template" -exec grep -E "__BUCKET_NAME__|__SOLUTION_NAME__|__VERSION__|__TEMPLATE_BUCKET_NAME__" {} +
    echo "DEBUG Note: You should see nothing above"
    echo "DEBUG The total count of *.template files in $template_dist_dir"
    find $template_dist_dir -name "*.template" | wc -l
    echo "DEBUG The total count of *.yaml files in $template_dist_dir"
    find $template_dist_dir -name "*.yaml" | wc -l
    echo "DEBUG Note: 0 is expected for *.yaml files"
    echo "DEBUG The total count of all files in $template_dist_dir"
    ls $template_dist_dir | wc -l
fi

echo "------------------------------------------------------------------------------"
echo "Gathering PS1 scripts"
echo "------------------------------------------------------------------------------"

echo "copy PS1 templates scripts to $build_dist_dir"
find $source_dir -type f \( -iname \*.ps1 -o -iname \*.Ps1 \) -exec cp "{}" $build_dist_dir \;

if [ "$DEBUG" = true ] ; then
    echo "DEBUG The total count of *.ps1 files in $build_dist_dir"
    find $build_dist_dir -name "*.ps1" | wc -l
fi

echo "------------------------------------------------------------------------------"
echo "Building Source Zip files"
echo "------------------------------------------------------------------------------"
cd $source_dir/

echo "Building boto3-layer.zip"

echo "Removing Package dir:"
rm -rf package

echo "Creating staging dir."
mkdir -p package/python
echo "PIP install boto3 crhelper"
PIP_COMMAND='pip3'
if ! command -v $PIP_COMMAND &> /dev/null
then
    echo "$PIP_COMMAND could not be found"
    PIP_COMMAND = 'pip'
    echo "Using $PIP_COMMAND instead"
fi
$PIP_COMMAND install --target=package/python boto3 crhelper botocore
cd package
echo "Zip python/* to boto3-layer.zip"
zip -r9 -q 'boto3-layer.zip' . -i 'python/*'
echo "cp boto3-layer.zip $build_dist_dir/boto3-layer.zip"
cp boto3-layer.zip $build_dist_dir/boto3-layer.zip

cd $source_dir/
## fgw-fileshare
echo "rm fgw-fileshare.zip"
rm fgw-fileshare.zip
echo "zip -r9q 'fgw-fileshare.zip' fgw-fileshare.py"
zip -r9q 'fgw-fileshare.zip' fgw-fileshare.py
echo "cp fgw-fileshare.zip $build_dist_dir/fgw-fileshare.zip"
cp fgw-fileshare.zip $build_dist_dir/fgw-fileshare.zip

## fsx-dns-name
echo "rm fsx-dns-name.zip"
rm fsx-dns-name.zip
echo "zip -r9q 'fsx-dns-name.zip' fsx-dns-name.py"
zip -r9q 'fsx-dns-name.zip' fsx-dns-name.py
echo "cp fsx-dns-name.zip $build_dist_dir/fsx-dns-name.zip"
cp fsx-dns-name.zip $build_dist_dir/fsx-dns-name.zip

## AWSQuickStart
echo "rm AWSQuickStart.zip"
rm AWSQuickStart.zip
echo "zip -r9 -q 'AWSQuickStart.zip' . -i 'AWSQuickStart/*'"
zip -r9 -q 'AWSQuickStart.zip' . -i 'AWSQuickStart/*'
echo "cp AWSQuickStart.zip $build_dist_dir/AWSQuickStart.zip"
cp AWSQuickStart.zip $build_dist_dir/AWSQuickStart.zip