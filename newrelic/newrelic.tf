resource "newrelic_alert_policy" "newrelic-alerts" {
  name                = "New Relic Related Alerts"
  incident_preference = "PER_CONDITION_AND_TARGET" # PER_POLICY is default
}

resource "newrelic_alert_policy_channel" "newrelic-alerts" {
  policy_id = newrelic_alert_policy.newrelic-alerts.id
  channel_ids = [
    #newrelic_alert_channel.email-channel.id,
    newrelic_alert_channel.pagerduty.id,
    newrelic_alert_channel.slack-channel.id
  ]
}

resource "newrelic_alert_policy" "newrelic-alerts-slack" {
  name                = "New Relic Related Alerts Slack"
  incident_preference = "PER_CONDITION_AND_TARGET" # PER_POLICY is default
}

resource "newrelic_alert_policy_channel" "newrelic-alerts-slack" {
  policy_id = newrelic_alert_policy.newrelic-alerts-slack.id
  channel_ids = [
    newrelic_alert_channel.slack-channel.id
  ]
}

resource "newrelic_nrql_alert_condition" "greater-than-30k-logs-per-hour" {
  account_id                   = data.aws_ssm_parameter.account-id.value
  policy_id                    = newrelic_alert_policy.newrelic-alerts.id
  type                         = "static"
  name                         = "More than 30k logs per hour being ingested"
  enabled                      = true
  violation_time_limit_seconds = 3600
  value_function               = "single_value"

  fill_option = "none"

  aggregation_window             = 60
  expiration_duration            = 3600
  open_violation_on_expiration   = true
  close_violations_on_expiration = false

  nrql {
    query             = <<EOF
      FROM Log
      SELECT rate(count(*), 1 hour)
      EOF
    evaluation_offset = 3
  }

  critical {
    operator              = "above"
    threshold             = 30000
    threshold_duration    = 600
    threshold_occurrences = "ALL"
  }
}
