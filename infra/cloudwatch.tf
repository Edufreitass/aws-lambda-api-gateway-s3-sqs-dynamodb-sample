resource "aws_cloudwatch_log_group" "batch_upload_lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.batch_upload_lambda.function_name}"
  retention_in_days = 1
}
