import json
import boto3
import os

rekognition = boto3.client('rekognition')
sns = boto3.client('sns')

S3_BUCKET = os.environ['S3_BUCKET']
SNS_TOPIC_ARN = os.environ['SNS_TOPIC_ARN']

def lambda_handler(event, context):
    # Get uploaded video info from S3 event
    s3_record = event['Records'][0]['s3']
    video_key = s3_record['object']['key']

    # Call Rekognition to analyze video
    response = rekognition.start_label_detection(
        Video={'S3Object': {'Bucket': S3_BUCKET, 'Name': video_key}}
    )

    job_id = response['JobId']

    # Assume we check later and find a "person" detected
    detected_person = True  # This would be the actual result from Rekognition

    if detected_person:
        # Trigger SNS alert if a person is detected
        sns.publish(
            TopicArn=SNS_TOPIC_ARN,
            Message=f"Alert: A person was detected in video {video_key}",
            Subject="Smart Home Alert"
        )

    return {
        "statusCode": 200,
        "body": json.dumps({"message": "Rekognition analysis started", "job_id": job_id})
    }
