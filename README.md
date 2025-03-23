# Smart Surveillance IoT Infrastructure

## Overview
This project implements a smart surveillance system using AWS services. The system captures live video streams, processes metadata, analyzes video content, and securely stores data for analysis and retrieval. The infrastructure is deployed using Terraform.

## Architecture
### Key Components:
- **Amazon Kinesis Video Streams** – Captures and streams live video from smart cameras.
- **AWS Lambda (Extract Metadata Function)** – Processes video metadata and stores relevant details.
- **AWS Lambda (Analyze Video Function)** – Uses Amazon Rekognition to analyze video frames for object detection and alerts.
- **Amazon DynamoDB** – Stores video metadata for easy querying.
- **Amazon S3** – Stores recorded video files.
- **Amazon SNS** – Sends alerts when certain objects or activities are detected.
- **Amazon API Gateway** – Provides a secure endpoint for interacting with the system.

## Files and Directories
### Terraform Configuration:
- `main.tf` – Defines the AWS resources and infrastructure setup.

### AWS Services Implemented:
- **IoT Core (Removed in favor of Kinesis)** – Initially used for processing but later optimized.
- **Kinesis Video Streams** – Handles video input and streaming.
- **Lambda (Extract Metadata Function)** – Extracts and processes video metadata.
- **Lambda (Analyze Video Function)** – Analyzes video frames using AWS Rekognition.
- **DynamoDB** – Stores structured metadata for efficient lookup.
- **S3** – Saves actual video footage.
- **SNS** – Sends alerts based on detected events.
- **API Gateway** – Exposes APIs for metadata retrieval.

## How It Works
1. **Video Capture** – Smart cameras send video streams to Kinesis Video Streams.
2. **Metadata Extraction** – A Lambda function extracts metadata (timestamp, camera ID, etc.).
3. **Metadata Storage** – The metadata is stored in DynamoDB for quick queries.
4. **Video Storage** – The full video recordings are saved in Amazon S3.
5. **Video Analysis** – A second Lambda function processes frames using AWS Rekognition to detect objects and trigger alerts.
6. **Alerts & Notifications** – If Rekognition detects an event, SNS sends an alert.
7. **API Access** – Users can retrieve metadata via API Gateway.

## Deployment
To deploy this project:
1. Ensure you have Terraform installed.
2. Initialize Terraform: `terraform init`
3. Plan the deployment: `terraform plan`
4. Apply the deployment: `terraform apply`

## Future Enhancements
- Implement AI-based video analysis for facial recognition.
- Add more event-driven alerts using AWS SNS.
- Improve API security with authentication and authorization.
- Introduce real-time dashboard visualization for detected events.

## License
This project is open-source and available for use.
