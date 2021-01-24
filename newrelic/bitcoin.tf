resource "newrelic_alert_policy" "bitcoin-alerts" {
  name                = "Bitcoin Alerts"
  incident_preference = "PER_CONDITION_AND_TARGET" # PER_POLICY is default
}

resource "newrelic_alert_policy_channel" "bitcoin-alerts" {
  policy_id = newrelic_alert_policy.bitcoin-alerts.id
  channel_ids = [
    #newrelic_alert_channel.email-channel.id,
    newrelic_alert_channel.slack-channel.id
  ]
}

resource "newrelic_nrql_alert_condition" "electrumx-not-running" {
  account_id                   = data.aws_ssm_parameter.account-id.value
  policy_id                    = newrelic_alert_policy.bitcoin-alerts.id
  type                         = "static"
  name                         = "Electrumx is not running"
  enabled                      = true
  violation_time_limit_seconds = 3600
  value_function               = "single_value"

  fill_option = "none"

  aggregation_window             = 60
  expiration_duration            = 120
  open_violation_on_expiration   = false
  close_violations_on_expiration = false

  nrql {
    query             = replace(var.nrql-container-not-running, "nrql-container-name", "electrumx")
    evaluation_offset = 3
  }

  critical {
    operator              = "equals"
    threshold             = 0
    threshold_duration    = 300
    threshold_occurrences = "ALL"
  }
}

resource "newrelic_nrql_alert_condition" "bitcoin-not-running" {
  account_id                   = data.aws_ssm_parameter.account-id.value
  policy_id                    = newrelic_alert_policy.bitcoin-alerts.id
  type                         = "static"
  name                         = "Bitcoin is not running"
  enabled                      = true
  violation_time_limit_seconds = 3600
  value_function               = "single_value"

  fill_option = "none"

  aggregation_window             = 60
  expiration_duration            = 120
  open_violation_on_expiration   = false
  close_violations_on_expiration = false

  nrql {
    query             = replace(var.nrql-container-not-running, "nrql-container-name", "bitcoin")
    evaluation_offset = 3
  }

  critical {
    operator              = "equals"
    threshold             = 0
    threshold_duration    = 300
    threshold_occurrences = "ALL"
  }
}
