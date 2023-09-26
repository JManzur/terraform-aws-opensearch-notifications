variable "webhook_url_ssm_parameter_name" {
  type        = string
  description = "The SSM Parameter Name for the Teams Chat Webhook URL"
  default     = "" # Empty string is allowed if var.webhook_url is not empty
}

variable "webhook_url" {
  type        = string
  description = "The Incoming Webhook URL for the Teams Chat"
  default     = "" # Empty string is allowed if var.webhook_url_ssm_parameter_name is not empty
}

variable "teams_channel_name" {
  type        = string
  description = "[OPTIONAL] The Teams Channel Name to send the message to"
  default     = "" # Empty string is allowed if var.webhook_url_ssm_parameter_name is not empty
}

variable "email_targets" {
  type        = list(string)
  description = "[OPTIONAL] The list of email addresses to send the message to"

  # ATTENTION:
  # - Email subscribers will receive a confirmation email with a link that they need to click to confirm the subscription.
  # - Subscription will remain pending until the user confirms the subscription.
  # - Confirmation email might land in the spam folder.

  default = [] # Empty list is allowed
}