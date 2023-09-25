output "sns_topic_arn" {
  value       = aws_sns_topic.opensearch_notifications.arn
  description = "The ARN of the SNS topic for OpenSearch notifications"
}

output "opensearch_to_sns_iam_role_arn" {
  value       = aws_iam_role.opensearch_to_sns.arn
  description = "The ARN of the IAM role for OpenSearch to send notifications to the SNS topic"
}
