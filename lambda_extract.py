import json
import boto3
import os
from datetime import datetime

s3 = boto3.client('s3')
dynamodb = boto3.resource('dynamodb')

S3_BUCKET = os.environ['S3_BUCKET']
DYNAMO_TABLE = os.environ['DYNAMO_TABLE']

def lambda_handler(event, context):
    # Simulate extracting metadata (in real use, extract from video stream)
    metadata = {
        "camera_id": "Camera_01",
        "timestamp": str(datetime.utcnow()),
        "motion_detected": True  # Example flag
    }

    # Save metadata to DynamoDB
    table = dynamodb.Table(DYNAMO_TABLE)
    table.put_item(Item=metadata)

    # Upload a placeholder video file to S3 (in real use, store actual video)
    video_key = f"videos/{metadata['timestamp']}.mp4"
    s3.put_object(Bucket=S3_BUCKET, Key=video_key, Body="Simulated Video Data")

    return {
        "statusCode": 200,
        "body": json.dumps({"message": "Metadata saved and video uploaded", "video_key": video_key})
    }
