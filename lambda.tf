################# Lambda ##################

# Create Bucket
resource "aws_s3_bucket" "lambda-function-bucket" {
  bucket = "lambda-viewcount-function-sph"

  tags = {
    Name = "Container for Lambda Function."
  }
}

# Zip Python Script
data "archive_file" "lambda-function-file" {
  type = "zip"

  source_dir  = "./lambda-function"
  output_path = "./lambda-function.zip"
}

# Add Python Script to S3 Bucket
resource "aws_s3_object" "lambda-function-object" {
  bucket = aws_s3_bucket.lambda-function-bucket.id

  key    = "lambda_function.zip"
  source = data.archive_file.lambda-function-file.output_path

  etag = filemd5(data.archive_file.lambda-function-file.output_path)
}

# Lambda Function
resource "aws_lambda_function" "lambda-function-viewcount" {
  function_name = "viewcount"

  s3_bucket = aws_s3_bucket.lambda-function-bucket.id
  s3_key    = aws_s3_object.lambda-function-object.key

  runtime = "python3.10"
  handler = "${var.lambda-function-file-name}.lambda_handler"

  source_code_hash = data.archive_file.lambda-function-file.output_base64sha256

  role = aws_iam_role.viewcount-function-role.arn

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.viewcount-table.name
    }
  }
}

# Lambda CloudWatch Log Group
resource "aws_cloudwatch_log_group" "lambda-function-logs" {
  name = "/aws/lambda/${aws_lambda_function.lambda-function-viewcount.function_name}"

  retention_in_days = 30
}

# Create Lambda Execution Role
resource "aws_iam_role" "viewcount-function-role" {
  name = "viewcount-function-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "lambda.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

# Attach AWSLambdaBasicExecutionRole Policy to viewcount-function-role
resource "aws_iam_role_policy_attachment" "AWSLambdaBasicExecutionRole" {
  role       = aws_iam_role.viewcount-function-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Attach AmazonDynamoDBFullAccess Policy to viewcount-function-role
resource "aws_iam_role_policy_attachment" "AmazonDynamoDBFullAccess" {
  role       = aws_iam_role.viewcount-function-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}