import unittest
from unittest.mock import patch, MagicMock
import importlib 

class TestHandler(unittest.TestCase):

    @patch('os.environ', {'SendAnonymizedMetric': 'Yes', 'botoConfig': '{}'})
    @patch('boto3.client')
    def test_create(self, mock_fsx_client):
        fsx_dns_name = importlib.import_module("fsx-dns-name") 
        event = {
            'RequestType': 'Create',
            'ResourceProperties': {
                'FileSystemId': 'fs-1234567890'
            }
        }
        context = {}
        mock_fsx_client.return_value.describe_file_systems.return_value = {
            'FileSystems': [{
                'DNSName': 'fsx-dns-name.example.com'
            }]
        }

        # Call the create function
        result = fsx_dns_name.create(event, context)

        # Assertions
        self.assertEqual(result, 'fsx-dns-name.example.com')
        self.assertEqual(fsx_dns_name.helper.Data['FSxDNSName'], 'fsx-dns-name.example.com')
        mock_fsx_client.return_value.describe_file_systems.assert_called_once_with(FileSystemIds=['fs-1234567890'])


if __name__ == '__main__':
    unittest.main()