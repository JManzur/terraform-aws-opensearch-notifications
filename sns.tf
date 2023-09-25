resource "aws_sns_topic" "opensearch_notifications" {
  name              = "OpenSearch-Notifications"
  kms_master_key_id = "alias/aws/sns" #tfsec:ignore:aws-sns-topic-encryption-use-cmk
}

resource "aws_sns_topic_subscription" "ms_teams_notifications" {
  topic_arn = aws_sns_topic.opensearch_notifications.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.opensearch_notifications.arn
}