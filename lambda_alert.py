import json
import boto3
import os

sns = boto3.client('sns')
SNS_TOPIC_ARN = os.environ['SNS_TOPIC_ARN']

def lambda_handler(event, context):
    # Extract the message from the Rekognition analysis
    message = json.loads(event['Records'][0]['Sns']['Message'])
    alert_message = message.get('Message', 'Unknown Alert')

    # Send SNS Notification
    sns.publish(
        TopicArn=SNS_TOPIC_ARN,
        Message=alert_message,
        Subject="Smart Home Security Alert"
    )

    return {
        "statusCode": 200,
        "body": json.dumps({"message": "Alert sent successfully"})
    }
