resource "aws_sqs_queue" "batch_user_registration_queue" {
  name                       = "batch-user-registration-queue"
  visibility_timeout_seconds = 60    # 1 minuto
  message_retention_seconds  = 86400 # 1 dia
  delay_seconds              = 0
  receive_wait_time_seconds  = 0

  tags = {
    Environment = "dev"
    Project     = "BatchUserRegistration"
  }
}
