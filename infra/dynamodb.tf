resource "aws_dynamodb_table" "user_registration_table" {
  name         = "user_registration"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "PK"
  range_key    = "SK"

  attribute {
    name = "PK"
    type = "S"
  }

  attribute {
    name = "SK"
    type = "S"
  }

  tags = {
    Name        = "user_registration_table"
    Environment = "dev"
  }
}
