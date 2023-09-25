locals {
  teams_channel_name = length(var.teams_channel_name) > 0 ? lower(replace(var.teams_channel_name, " ", "-")) : "notifications-channel"
}

# This resource is only created if var.webhook_url_ssm_parameter_name is not empty and var.webhook_url is empty
resource "aws_ssm_parameter" "ms_teams_webhook_url" {
  count = length(var.webhook_url_ssm_parameter_name) > 0 && length(var.webhook_url) == 0 ? 0 : 1

  name        = "/ms-teams/${local.teams_channel_name}/webhook-url"
  description = "MS Teams Webhook URL"
  type        = "SecureString" # Encrypted string using default SSM KMS key
  value       = var.webhook_url

  tags = { Ref = "MS-Teams-Webhook-URL" }
}