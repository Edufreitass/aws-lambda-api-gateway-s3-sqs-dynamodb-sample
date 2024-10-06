resource "aws_iam_role_policy" "batch_upload_lambda_exec_policy" {
  name = "batch_upload_lambda_exec_policy"
  role = aws_iam_role.batch_upload_lambda_exec_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "xray:PutTraceSegments",
          "xray:PutTelemetryRecords",
          "dynamodb:PutItem",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "s3:GetObject"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy" "s3_to_sqs_policy" {
  name = "s3_to_sqs_policy"
  role = aws_iam_role.batch_upload_lambda_exec_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "sqs:SendMessage",
        Effect   = "Allow",
        Resource = aws_sqs_queue.batch_user_registration_queue.arn
      },
      {
        Action   = "s3:GetBucketNotification",
        Effect   = "Allow",
        Resource = aws_s3_bucket.user_upload_bucket.arn
      }
    ]
  })
}