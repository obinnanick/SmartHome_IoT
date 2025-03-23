provider "aws" {
  region = "us-east-1"
}
resource "aws_kinesis_video_stream" "video_stream" {
  name = "smart_home_stream"
  data_retention_in_hours = 24
  
}
resource "aws_iam_role" "lambda_role" {
  name = "LambdaExecutionRole"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_dynamodb_table" "video_metadata" {
  name         = "VideoMetadata"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "video_id"

  attribute {
    name = "video_id"
    type = "S"
  }

  attribute {
    name = "timestamp"
    type = "N"
  }
  global_secondary_index {
    name               = "TimestampIndex"
    hash_key           = "timestamp"
    projection_type    = "ALL"
  }
}

resource "aws_lambda_function" "extract_metadata" {
  function_name    = "ExtractMetadataFunction"
  role             = aws_iam_role.lambda_role.arn
  handler         = "index.handler"
  runtime        = "python3.8"

  filename         = "lambda_extract.zip"
  source_code_hash = filebase64sha256("lambda_extract.zip")

  environment {
    variables = {
      DYNAMO_TABLE = aws_dynamodb_table.video_metadata.name
      S3_BUCKET    = aws_s3_bucket.video_storage.bucket
    }
  }
}
resource "aws_s3_bucket" "video_storage" {
  bucket = "smart-home-video-storage95"
}
resource "aws_s3_bucket_policy" "video_bucket_policy" {
  bucket = aws_s3_bucket.video_storage.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = aws_iam_role.lambda_role.arn  # Only allows Lambda role
        },
        Action = "s3:GetObject",
        Resource = "${aws_s3_bucket.video_storage.arn}/*"
      }
    ]
  }
  )
}

resource "aws_lambda_function" "analyze_video" {
  function_name    = "AnalyzeVideoFunction"  
  role             = aws_iam_role.lambda_role.arn  
  handler         = "index.handler"  # Entry point for the Lambda function
  runtime        = "python3.8"  

  filename         = "lambda_analyze.zip"  # The ZIP file containing the Lambda code
  source_code_hash = filebase64sha256("lambda_analyze.zip")  

  environment {
    variables = {
      S3_BUCKET      = aws_s3_bucket.video_storage.bucket  
      SNS_TOPIC_ARN  = aws_sns_topic.alerts.arn  
  }
}
}
resource "aws_lambda_function" "send_alerts" {
  function_name    = "SendAlertsFunction"
  role             = aws_iam_role.lambda_role.arn
  handler         = "index.handler"
  runtime        = "python3.8"

  filename         = "lambda_alert.zip"
  source_code_hash = filebase64sha256("lambda_alert.zip")

  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.alerts.arn
    }
  }
}
resource "aws_sns_topic" "alerts" {
  name = "SmartHomeAlerts"
}

resource "aws_sns_topic_subscription" "email_subscriber" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = "nickabuguobinna@gmail.com"  
}
