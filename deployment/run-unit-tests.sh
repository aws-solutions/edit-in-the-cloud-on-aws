#!/bin/bash
#
# This assumes all of the OS-level configuration has been completed and git repo has already been cloned
#
# This script should be run from the repo's deployment directory
# cd deployment
# ./run-unit-tests.sh
#
# Get reference for all important folders
declare -r root_dir="$(cd "`dirname "${BASH_SOURCE[0]}"`/.."; pwd)"
source_dir="$root_dir/source"
custom_resource_dir="$source_dir/custom-resource"

# launch python unit tests for cfn_check.py
coverage run -m unit_tests
coverage xml
sed 's/filename="/filename="deployment\//g' coverage.xml > coverage_sonarqube.xml && mv coverage_sonarqube.xml coverage.xml

echo coverage report coverage.xml created

# launch python unit tests for fsx-dns-name.py
cd $source_dir
pip install -r requirements.txt
coverage run -m fsx-dns-name-unit-tests
coverage xml
sed 's/filename="/filename="source\//g' coverage.xml > coverage_sonarqube.xml && mv coverage_sonarqube.xml coverage.xml

run_component_test() {
    local component_path=$1
    local component_name=$2

    echo "------------------------------------------------------------------------------"
    echo "[Test] $component_name"
    echo "------------------------------------------------------------------------------"
    cd "$component_path"

    # install and build for unit testing
    npm install

    # run unit tests
    npm run test

}

run_component_test $custom_resource_dir 'Custom Resource'
