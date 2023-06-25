import boto3
import os
import json

def lambda_handler(event: any, context: any):
    
    # Create a DynamoDB client
    dynamodb = boto3.resource("dynamodb")
    table_name = os.environ["TABLE_NAME"]
    table = dynamodb.Table(table_name)
    
    # Get current viewcount value
    viewcount =  table.get_item(Key={'page-visit': 'True'})['Item']['viewcount']
    
    # Increment viewcount by 1
    updated_viewcount = viewcount + 1
    
    # Add new viewcount value to table
    table.put_item(Item={'page-visit': 'True', "viewcount": updated_viewcount})
    
    # Return API response in JSON format
    return {
    'statusCode': 200,
    'headers': {
        'Content-Type': 'application/json',
    },
    'body': updated_viewcount
    }