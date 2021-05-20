"""
http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing,
software distributed under the License is distributed on an
"AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
KIND, either express or implied.  See the License for the
specific language governing permissions and limitations
under the License.
"""

import json
import boto3
from crhelper import CfnResource
import logging

# Get boto config. 
# config = config.Config({"user_agent_extra": "AwsSolution/aws-edit-in-the-cloud/v1.0.0"})

logger = logging.getLogger(__name__)
# Initialise the helper, all inputs are optional, this example shows the defaults
helper = CfnResource(json_logging=False, log_level='INFO', boto_level='CRITICAL')

try:
    ## Init code goes here
    pass
except Exception as e:
    helper.init_failure(e)

@helper.create
def create(event, context):
    logger.info("Got Create")
    logger.info(event)
    # Optionally return an ID that will be used for the resource PhysicalResourceId, 
    # if None is returned an ID will be generated. If a poll_create function is defined 
    # return value is placed into the poll event as event['CrHelperData']['PhysicalResourceId']
    #
    # To add response data update the helper.Data dict
    # If poll is enabled data is placed into poll event as event['CrHelperData']
    """
    Create a Storage Gateway File Share
    """
    storagegateway = boto3.client('storagegateway')

    # Parameters
    request_id = event['RequestId']
    # CHANGE START:
    # BY: Sachin Holla ON: 2/17/20
    # TO: use the gateway_name as the input param and not the ARN directly 
    #     (since this is created in the EC2 instance and its not easy to export via CFN)
    #
    #gateway_ARN = event['ResourceProperties']['GatewayARN']
    gateway_name = event['ResourceProperties']['GatewayName']
    logger.info(f"gateway_name - {gateway_name}")
    # now find the corresponding gateway_arn
    gateway_ARN = ""
    sgw_list = storagegateway.list_gateways()
    for sgw in sgw_list["Gateways"]:
        if sgw["GatewayName"] == gateway_name:
            logger.info(sgw)
            gateway_ARN = sgw["GatewayARN"]
    # CHANGE END/
    gateway_role = event['ResourceProperties']['RoleARN']
    s3_bucket = event['ResourceProperties']['FileShareBucket']
    location_ARN = 'arn:aws:s3:::' + s3_bucket

    logger.info(f"gateway_ARN - {gateway_ARN}")
    logger.info(f"gateway_role - {gateway_role}")
    logger.info(f"location_ARN - {location_ARN}")

    # Get SGW Info
    response = storagegateway.describe_gateway_information(GatewayARN=gateway_ARN)
    logger.info(json.dumps(response))
    ip_v4_address = response['GatewayNetworkInterfaces'][0]['Ipv4Address']
    network_share = "\\\\" + ip_v4_address + "\\" + s3_bucket
    
    # Request Arguements
    request_args = {
        'ClientToken': request_id,
        'GatewayARN': gateway_ARN,
        'Role': gateway_role,
        'LocationARN': location_ARN,
        'SMBACLEnabled': True,
        'GuessMIMETypeEnabled': True,
        'ObjectACL': 'bucket-owner-full-control'
    }

    # Request
    try:
        response = storagegateway.create_smb_file_share(**request_args)
        logger.info(json.dumps(response))
        file_share_arn = response['FileShareARN']
        file_share_id = file_share_arn.split('/')[-1]
        helper.Data.update({
            "FileShareArn": file_share_arn,
            "FileShareId": file_share_id,
            "NetworkShare": network_share
        })

    except Exception as ex:
        logging.error(ex)
        return False

    # Used in 'delete' action as PhysicalResourceId
    return file_share_arn

@helper.update
def update(event, context):
    logger.info("Got Update")
    logger.info(event)
    # If the update resulted in a new resource being created, return an id for the new resource. 
    # CloudFormation will send a delete event with the old id when stack update completes

    return True
    
@helper.delete
def delete(event, context):
    logger.info("Got Delete")
    logger.info(event)
    # Delete never returns anything. Should not fail if the underlying resources are already deleted.
    # Desired state.

    storagegateway = boto3.client('storagegateway')
    file_share_arn = event["PhysicalResourceId"]

    try:
        storagegateway.delete_file_share(FileShareARN=file_share_arn)

    except Exception as ex:
        logging.error(ex)
        return False

    return True

@helper.poll_create
def poll_create(event, context):
    logger.info("Got create poll")
    logger.info(event)
    # Return a resource id or True to indicate that creation is complete. if True is returned an id 
    # will be generated
    
    file_share_arn = event['CrHelperData']['PhysicalResourceId']
    helper.Data.update({"FileShareArn": file_share_arn})
    
    # Used in 'delete' action as PhysicalResourceId    
    return file_share_arn

def handler(event, context):
    helper(event, context)
