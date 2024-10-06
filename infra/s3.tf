resource "aws_s3_bucket" "user_upload_bucket" {
  bucket = "user-upload-bucket-${random_id.bucket_suffix.hex}"

  tags = {
    Name        = "User Upload Bucket"
    Environment = "Dev"
  }
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# resource "aws_s3_bucket_notification" "example_bucket_notification" {
#   bucket = aws_s3_bucket.user_upload_bucket.id

#   queue {
#     queue_arn = aws_sqs_queue.batch_user_registration_queue.arn
#     events    = ["s3:ObjectCreated:*"]
#     filter_suffix = ".csv"
#   }

#   depends_on = [ aws_s3_bucket.user_upload_bucket ]
# }
