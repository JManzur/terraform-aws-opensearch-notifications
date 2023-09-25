data "archive_file" "opensearch_notifications" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_code/"
  output_path = "${path.module}/output_lambda_zip/opensearch_notifications.zip"
}

resource "aws_lambda_function" "opensearch_notifications" {
  filename      = data.archive_file.opensearch_notifications.output_path
  function_name = "OpenSearch-Notifications"
  role          = aws_iam_role.opensearch_notifications.arn
  handler       = "main_handler.lambda_handler"
  description   = "OpenSearch-Notifications"
  tags          = { Name = "OpenSearch-Notifications" }

  source_code_hash = data.archive_file.opensearch_notifications.output_path
  runtime          = "python3.9"
  timeout          = "900"

  environment {
    variables = {
      ms_teams_webhook_url = length(var.webhook_url_ssm_parameter_name) > 0 ? var.webhook_url_ssm_parameter_name : aws_ssm_parameter.ms_teams_webhook_url[0].name
    }
  }
  tracing_config {
    mode = "Active"
  }
}

resource "aws_lambda_permission" "sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.opensearch_notifications.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.opensearch_notifications.arn
}