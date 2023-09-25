data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

locals {
  aws_account_id     = data.aws_caller_identity.current.account_id
  aws_region         = data.aws_region.current.name
  ssm_parameter_name = length(var.webhook_url_ssm_parameter_name) > 0 ? var.webhook_url_ssm_parameter_name : aws_ssm_parameter.ms_teams_webhook_url[0].name
}

# IAM Policy Source
data "aws_iam_policy_document" "opensearch_notifications_policy" {
  statement {
    sid    = "CloudWatchAccess"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:${local.aws_region}:${local.aws_account_id}:*"]
  }

  statement {
    sid    = "GetParameter"
    effect = "Allow"
    actions = [
      "ssm:GetParameters",
      "ssm:GetParameter"
    ]
    resources = ["arn:aws:ssm:${local.aws_region}:${local.aws_account_id}:parameter${local.ssm_parameter_name}"]
  }

  statement {
    sid    = "KMSDecrypt"
    effect = "Allow"
    actions = [
      "kms:Decrypt"
    ]
    resources = ["arn:aws:kms:${local.aws_region}:${local.aws_account_id}:key/alias/aws/ssm"]
  }
}

data "aws_iam_policy_document" "opensearch_notifications_assume" {
  statement {
    sid    = "LambdaAssumeRole"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

# IAM Policy
resource "aws_iam_policy" "opensearch_notifications" {
  name        = "OpenSearch-Notifications-Lambda-Policy"
  path        = "/"
  description = "Permissions to trigger the Lambda"
  policy      = data.aws_iam_policy_document.opensearch_notifications_policy.json
  tags        = { Name = "OpenSearch-Notifications-Lambda-Policy" }
}

# IAM Role (Lambda execution role)
resource "aws_iam_role" "opensearch_notifications" {
  name               = "OpenSearch-Notifications-Lambda-Role"
  assume_role_policy = data.aws_iam_policy_document.opensearch_notifications_assume.json
  tags               = { Name = "OpenSearch-Notifications-Lambda-Role" }
}

# Attach Role and Policy
resource "aws_iam_role_policy_attachment" "opensearch_notifications" {
  role       = aws_iam_role.opensearch_notifications.name
  policy_arn = aws_iam_policy.opensearch_notifications.arn
}


#######################################################################
### IAM Role to allow OpenSearch to send notifications to the SNS topic:

data "aws_iam_policy_document" "opensearch_to_sns" {
  statement {
    actions   = ["sns:Publish"]
    resources = ["*"]
  }
}

resource "aws_iam_role" "opensearch_to_sns" {
  name = "opensearch_to_sns_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "es.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "opensearch_to_sns" {
  name        = "opensearch_to_sns_policy"
  description = "Policy for allowing OpenSearch to send notifications to SNS"
  policy      = data.aws_iam_policy_document.opensearch_to_sns.json
}

resource "aws_iam_policy_attachment" "opensearch_to_sns" {
  name       = "opensearch_to_sns_attachment"
  policy_arn = aws_iam_policy.opensearch_to_sns.arn
  roles      = [aws_iam_role.opensearch_to_sns.name]
}