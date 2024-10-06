data "archive_file" "demo_lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../app"
  output_path = "${path.module}/lambda.zip"
}

data "archive_file" "layer_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../infra/libs/"
  output_path = "layer.zip"
  depends_on = [
    null_resource.install_layer_dependencies
  ]
}

resource "null_resource" "install_layer_dependencies" {
  provisioner "local-exec" {
    command = "pip install -r ${path.module}/../app/requirements.txt -t ${path.module}/../infra/libs/python/lib/python3.12/site-packages --upgrade" # --upgrade
  }
  triggers = {
    trigger = timestamp()
  }
}

#new
resource "null_resource" "cleanup_python_directory" {
  provisioner "local-exec" {
    command = "powershell.exe Remove-Item -Recurse -Force ${path.module}/../infra/libs/"
  }
  triggers = {
    always_run = timestamp()
  }
  depends_on = [
    data.archive_file.layer_zip
  ]
}

resource "aws_lambda_function" "demo_lambda" {
  function_name    = "demo-lambda"
  role             = aws_iam_role.lambda_exec_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.12"
  memory_size      = "128" #MB
  timeout          = 15    #sec
  filename         = data.archive_file.demo_lambda_zip.output_path
  source_code_hash = data.archive_file.demo_lambda_zip.output_base64sha256

  layers = [
    aws_lambda_layer_version.lambda_layer.arn
  ]

  depends_on = [
    data.archive_file.demo_lambda_zip,
    aws_lambda_layer_version.lambda_layer
  ]

  tracing_config {
    mode = "Active"
  }

  environment {
    variables = {
      ENV                     = "dev",
      POWERTOOLS_SERVICE_NAME = "demo",
      DYNAMODB_TABLE_NAME     = aws_dynamodb_table.example_table.name
    }
  }
}

resource "aws_lambda_layer_version" "lambda_layer" {
  filename         = "layer.zip"
  source_code_hash = data.archive_file.layer_zip.output_base64sha256
  layer_name       = "lambda_layer_name"

  compatible_runtimes = ["python3.12"]
  depends_on = [
    data.archive_file.layer_zip
  ]
}
