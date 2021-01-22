resource "newrelic_alert_policy" "web-checks" {
  name                = "Web Checks"
  incident_preference = "PER_CONDITION_AND_TARGET" # PER_POLICY is default
}

resource "aws_ssm_parameter" "email" {
  name  = "/global/newrelic/email"
  type  = "SecureString"
  value = ""

  lifecycle {
    ignore_changes = [value]
  }
}

resource "newrelic_alert_channel" "email-channel" {
  name = "me"
  type = "email"

  config {
    recipients              = aws_ssm_parameter.email.value
    include_json_attachment = "0"
  }
}

resource "aws_ssm_parameter" "slack-channel" {
  name  = "/global/newrelic/slack-channel"
  type  = "SecureString"
  value = ""

  lifecycle {
    ignore_changes = [value]
  }
}

resource "newrelic_alert_channel" "slack-channel" {
  name = "Slack"
  type = "slack"

  config {
    channel = "#fakechannel"
    url     = aws_ssm_parameter.slack-channel.value
  }
}

# Applies the created channels above to the alert policy
# referenced at the top of the config.
resource "newrelic_alert_policy_channel" "send-web-checks-to-slack" {
  policy_id = newrelic_alert_policy.web-checks.id
  channel_ids = [
    newrelic_alert_channel.slack-channel.id
  ]
}