# Configure the AWS provider
provider "aws" {
  region = "us-east-1"  # Replace with your region
}

# Create an AWS Lambda function
resource "aws_lambda_function" "my_lambda_function" {
  function_name = "my-lambda-function"
  role          = aws_iam_role.lambda_role.arn
  handler       = "com.example.MyHandler::handleRequest"
  runtime       = "java8"
  memory_size   = 256
  timeout       = 30

  # Upload the Spring Boot JAR to S3
  filename      = "application.jar"
  source_code_hash = filebase64sha256("path/to/your/application.jar")

  # Configure the environment variables for your Spring Boot application
  environment {
    variables = {
      SPRING_PROFILES_ACTIVE = "production"
      DB_URL                 = "jdbc:mysql://your-db-host:your-db-port/your-db-name"
      DB_NAME            = "your-db-name"
     
    }
  }
}

# Create an IAM role for the Lambda function
resource "aws_iam_role" "lambda_role" {
  name = "lambda-execution-role"

  assume_role_policy = <<EOF
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
EOF
}

# Attach the necessary IAM policy to the Lambda role
resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_role.name
}
