data "aws_iam_policy_document" "queue" {
  statement {
    effect = "Allow"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions   = ["sqs:SendMessage"]
    resources = ["arn:aws:sqs:*:*:*"]

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [aws_s3_bucket.user_upload_bucket.arn]
    }
  }
}

resource "aws_sqs_queue" "batch_user_registration_queue" {
  name                       = "batch-user-registration-queue"
  visibility_timeout_seconds = 60    # 1 minuto
  message_retention_seconds  = 86400 # 1 dia
  delay_seconds              = 0
  receive_wait_time_seconds  = 0
  policy                     = data.aws_iam_policy_document.queue.json

  tags = {
    Environment = "dev"
    Project     = "BatchUserRegistration"
  }
}
