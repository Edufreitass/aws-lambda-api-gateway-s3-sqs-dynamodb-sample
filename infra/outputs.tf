output "batch_user_registration_api_url" {
  value = aws_api_gateway_deployment.batch_user_registration_deployment.invoke_url
}

output "s3_bucket_name" {
  value = aws_s3_bucket.user_upload_bucket.bucket
}

output "sqs_queue_url" {
  value = aws_sqs_queue.batch_user_registration_queue.id
}

output "sqs_queue_arn" {
  value = aws_sqs_queue.batch_user_registration_queue.arn
}