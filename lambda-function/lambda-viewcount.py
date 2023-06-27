import boto3
import os
import json

def lambda_handler(event: any, context: any):

    # Create a DynamoDB client
    dynamodb = boto3.resource("dynamodb")
    table_name = os.environ["TABLE_NAME"]
    table = dynamodb.Table(table_name)

    # Does 'viewed' table item exist? If not, initialize with viewcount value of 0
    def get_key():
        key = table.get_item(Key={'viewed': 'True'})
        if 'Item' in key:
            return key['Item']
        else:
            table.put_item(Item={'viewed': 'True', "viewcount": 0})
            return table.get_item(Key={'viewed': 'True'})['Item']
    
    key = get_key()

    # Get current viewcount value
    viewcount = key['viewcount']

    # Increment viewcount by 1
    updated_viewcount = viewcount + 1

    # Add new viewcount value to table
    table.put_item(Item={'viewed': 'True', "viewcount": updated_viewcount})

    # Return API response in JSON format
    return {
        'statusCode': 200,
        'headers': {
            'Content-Type': 'application/json',
        },
        'body': updated_viewcount
    }