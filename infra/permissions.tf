resource "aws_lambda_permission" "batch_upload_lambda_permission" {
  statement_id  = "AllowAPIGatewayInvokeBatchUpload"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.batch_upload_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.batch_user_registration_api.execution_arn}/*/*"
}

resource "aws_lambda_event_source_mapping" "sqs_to_lambda" {
  event_source_arn = aws_sqs_queue.batch_user_registration_queue.arn
  function_name    = aws_lambda_function.batch_upload_lambda.arn
  enabled          = true
  batch_size       = 10 # Ajuste conforme necessário

  depends_on = [aws_lambda_permission.allow_sqs_invocation]
}

resource "aws_lambda_permission" "allow_sqs_invocation" {
  statement_id  = "AllowSQSInvocation"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.batch_upload_lambda.function_name
  principal     = "sqs.amazonaws.com"
  source_arn    = aws_sqs_queue.batch_user_registration_queue.arn
}
