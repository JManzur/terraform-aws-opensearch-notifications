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
  default     = "" # Empty string is allowed
}