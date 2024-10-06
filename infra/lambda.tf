data "archive_file" "batch_upload_lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../app"
  output_path = "${path.module}/batch_upload_lambda.zip"
}

data "archive_file" "batch_layer_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../infra/libs/"
  output_path = "batch_layer.zip"
  depends_on = [
    null_resource.install_batch_layer_dependencies
  ]
}

resource "null_resource" "install_batch_layer_dependencies" {
  provisioner "local-exec" {
    command = "pip install -r ${path.module}/../app/requirements.txt -t ${path.module}/../infra/libs/python/lib/python3.12/site-packages" # --upgrade
  }
  triggers = {
    trigger = timestamp()
  }
}

resource "null_resource" "cleanup_python_directory" {
  provisioner "local-exec" {
    command = "powershell.exe Remove-Item -Recurse -Force ${path.module}/../infra/libs/"
  }
  triggers = {
    always_run = timestamp()
  }
  depends_on = [
    data.archive_file.batch_layer_zip
  ]
}

resource "aws_lambda_function" "batch_upload_lambda" {
  function_name    = "batch-upload-lambda"
  role             = aws_iam_role.batch_upload_lambda_exec_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.12"
  memory_size      = "128" #MB
  timeout          = 15    #sec
  filename         = data.archive_file.batch_upload_lambda_zip.output_path
  source_code_hash = data.archive_file.batch_upload_lambda_zip.output_base64sha256

  layers = [
    aws_lambda_layer_version.batch_lambda_layer.arn
  ]

  depends_on = [
    data.archive_file.batch_upload_lambda_zip,
    aws_lambda_layer_version.batch_lambda_layer
  ]

  tracing_config {
    mode = "Active"
  }

  environment {
    variables = {
      ENV                     = "dev",
      POWERTOOLS_SERVICE_NAME = "batch_upload",
      DYNAMODB_TABLE_NAME     = aws_dynamodb_table.user_registration_table.name
    }
  }
}

resource "aws_lambda_layer_version" "batch_lambda_layer" {
  filename         = "batch_layer.zip"
  source_code_hash = data.archive_file.batch_layer_zip.output_base64sha256
  layer_name       = "batch_upload_lambda_layer"

  compatible_runtimes = ["python3.12"]
  depends_on = [
    data.archive_file.batch_layer_zip
  ]
}
