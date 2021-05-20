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
from botocore.config import Config
from crhelper import CfnResource
import logging


logger = logging.getLogger(__name__)
# Initialise the helper, all inputs are optional, this example shows the defaults

helper = CfnResource(json_logging=False, log_level='INFO', boto_level='CRITICAL')
try:
    ## Init code
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
    Get FSx DNS Name
    """
    conf = Config(user_agent_extra="AwsSolution/edit-in-the-cloud/v2.0.0")
    fsx_windows = boto3.client('fsx', config=conf)

    # Parameters, as a list
    file_system_id = [event['ResourceProperties']['FileSystemId']]

    logger.info(f"file_system_id - {file_system_id}")

    # Get SGW Info
    response = fsx_windows.describe_file_systems(FileSystemIds=file_system_id)
    logger.info(json.dumps(response, indent=4, sort_keys=True, default=str))
    fsx_dns_name = response['FileSystems'][0]['DNSName']
    logger.info(fsx_dns_name)
    
    # get FSx DNS Name
    helper.Data.update({
        "FSxDNSName": fsx_dns_name
    })

    # retrun gateway_arn used in 'delete' action as PhysicalResourceId
    return fsx_dns_name

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

    return True

@helper.poll_create
def poll_create(event, context):
    logger.info("Got create poll")
    logger.info(event)
    # Return a resource id or True to indicate that creation is complete. if True is returned an id 
    # will be generated
    
    fsx_dns_name = event['CrHelperData']['PhysicalResourceId']
    logger.info(fsx_dns_name)
    # get FSx DNS Name
    helper.Data.update({
        "FSxDNSName": fsx_dns_name
    })
    
    # Used in 'delete' action as PhysicalResourceId    
    return fsx_dns_name

def handler(event, context):
    helper(event, context)
