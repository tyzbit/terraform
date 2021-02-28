resource "aws_ssm_parameter" "email" {
  name  = "/global/newrelic/email"
  type  = "SecureString"
  value = ""

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "statuspage-qtosw-email" {
  name  = "/global/newrelic/statuspage-qtosw-email"
  type  = "SecureString"
  value = ""

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "statuspage-primary-plex-email" {
  name  = "/global/newrelic/statuspage-primary-plex-email"
  type  = "SecureString"
  value = ""

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "statuspage-secondary-plex-email" {
  name  = "/global/newrelic/statuspage-secondary-plex-email"
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

resource "newrelic_alert_channel" "pagerduty" {
  name = "Pagerduty"
  type = "pagerduty"

  config {
    service_key = data.aws_ssm_parameter.pagerduty-key.value
  }
}

resource "newrelic_alert_channel" "statuspage-qtosw-email" {
  name = "Statuspage - qtosw"
  type = "email"

  config {
    recipients              = aws_ssm_parameter.statuspage-qtosw-email.value
    include_json_attachment = "0"
  }
}

resource "newrelic_alert_channel" "statuspage-primary-plex-email" {
  name = "Statuspage - Primary Plex"
  type = "email"

  config {
    recipients              = aws_ssm_parameter.statuspage-primary-plex-email.value
    include_json_attachment = "0"
  }
}

resource "newrelic_alert_channel" "statuspage-secondary-plex-email" {
  name = "Statuspage - Secondary Plex"
  type = "email"

  config {
    recipients              = aws_ssm_parameter.statuspage-secondary-plex-email.value
    include_json_attachment = "0"
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
