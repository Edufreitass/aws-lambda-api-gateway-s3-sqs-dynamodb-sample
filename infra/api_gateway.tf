resource "aws_api_gateway_rest_api" "batch_user_registration_api" {
  name = "batch-user-registration-api"
}

resource "aws_api_gateway_resource" "batch_upload_resource" {
  rest_api_id = aws_api_gateway_rest_api.batch_user_registration_api.id
  parent_id   = aws_api_gateway_rest_api.batch_user_registration_api.root_resource_id
  path_part   = "batch-upload"
}

resource "aws_api_gateway_method" "batch_upload_post_method" {
  rest_api_id   = aws_api_gateway_rest_api.batch_user_registration_api.id
  resource_id   = aws_api_gateway_resource.batch_upload_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_batch_upload_integration" {
  rest_api_id             = aws_api_gateway_rest_api.batch_user_registration_api.id
  resource_id             = aws_api_gateway_resource.batch_upload_resource.id
  http_method             = aws_api_gateway_method.batch_upload_post_method.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.batch_upload_lambda.invoke_arn
}

resource "aws_api_gateway_deployment" "batch_user_registration_deployment" {
  depends_on = [aws_api_gateway_integration.lambda_batch_upload_integration]

  rest_api_id = aws_api_gateway_rest_api.batch_user_registration_api.id
  stage_name  = "dev"
}
