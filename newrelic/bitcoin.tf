resource "newrelic_alert_policy" "bitcoin-alerts" {
  name                = "Bitcoin Alerts"
  incident_preference = "PER_CONDITION_AND_TARGET" # PER_POLICY is default
}

resource "newrelic_alert_policy_channel" "bitcoin-alerts" {
  policy_id = newrelic_alert_policy.bitcoin-alerts.id
  channel_ids = [
    #newrelic_alert_channel.email-channel.id,
    newrelic_alert_channel.pagerduty.id,
    newrelic_alert_channel.slack-channel.id
  ]
}

resource "newrelic_nrql_alert_condition" "electrumx-not-running" {
  account_id                   = data.aws_ssm_parameter.account-id.value
  policy_id                    = newrelic_alert_policy.bitcoin-alerts.id
  type                         = "static"
  name                         = "Electrumx is not running"
  enabled                      = true
  violation_time_limit_seconds = var.nrql-container-not-running.violation_time_limit_seconds
  value_function               = var.nrql-container-not-running.value_function

  fill_option = var.nrql-container-not-running.fill_option

  aggregation_window             = var.nrql-container-not-running.aggregation_window
  expiration_duration            = var.nrql-container-not-running.expiration_duration
  open_violation_on_expiration   = var.nrql-container-not-running.open_violation_on_expiration
  close_violations_on_expiration = var.nrql-container-not-running.close_violations_on_expiration

  nrql {
    query             = replace(var.nrql-container-not-running.query, "nrql-container-name", "electrumx")
    evaluation_offset = var.nrql-container-not-running.evaluation_offset
  }

  critical {
    operator              = var.nrql-container-not-running.operator
    threshold             = var.nrql-container-not-running.threshold
    threshold_duration    = var.nrql-container-not-running.threshold_duration
    threshold_occurrences = var.nrql-container-not-running.threshold_occurrences
  }
}

resource "newrelic_nrql_alert_condition" "bitcoin-not-running" {
  account_id                   = data.aws_ssm_parameter.account-id.value
  policy_id                    = newrelic_alert_policy.bitcoin-alerts.id
  type                         = "static"
  name                         = "Bitcoin is not running"
  enabled                      = true
  violation_time_limit_seconds = var.nrql-container-not-running.violation_time_limit_seconds
  value_function               = var.nrql-container-not-running.value_function

  fill_option = var.nrql-container-not-running.fill_option

  aggregation_window             = var.nrql-container-not-running.aggregation_window
  expiration_duration            = var.nrql-container-not-running.expiration_duration
  open_violation_on_expiration   = var.nrql-container-not-running.open_violation_on_expiration
  close_violations_on_expiration = var.nrql-container-not-running.close_violations_on_expiration

  nrql {
    query             = replace(var.nrql-container-not-running.query, "nrql-container-name", "bitcoin")
    evaluation_offset = 3
  }

  critical {
    operator              = var.nrql-container-not-running.operator
    threshold             = var.nrql-container-not-running.threshold
    threshold_duration    = var.nrql-container-not-running.threshold_duration
    threshold_occurrences = var.nrql-container-not-running.threshold_occurrences
  }
}

resource "newrelic_nrql_alert_condition" "btc-rpc-explorer-not-running" {
  account_id                   = data.aws_ssm_parameter.account-id.value
  policy_id                    = newrelic_alert_policy.bitcoin-alerts.id
  type                         = "static"
  name                         = "BTC-RPC-Explorer is not running"
  enabled                      = true
  violation_time_limit_seconds = var.nrql-container-not-running.violation_time_limit_seconds
  value_function               = var.nrql-container-not-running.value_function

  fill_option = var.nrql-container-not-running.fill_option

  aggregation_window             = var.nrql-container-not-running.aggregation_window
  expiration_duration            = var.nrql-container-not-running.expiration_duration
  open_violation_on_expiration   = var.nrql-container-not-running.open_violation_on_expiration
  close_violations_on_expiration = var.nrql-container-not-running.close_violations_on_expiration

  nrql {
    query             = replace(var.nrql-container-not-running.query, "nrql-container-name", "btc-rpc-explorer")
    evaluation_offset = 3
  }

  critical {
    operator              = var.nrql-container-not-running.operator
    threshold             = var.nrql-container-not-running.threshold
    threshold_duration    = var.nrql-container-not-running.threshold_duration
    threshold_occurrences = var.nrql-container-not-running.threshold_occurrences
  }
}

resource "newrelic_nrql_alert_condition" "btc-rpc-explorer-cache-not-running" {
  account_id                   = data.aws_ssm_parameter.account-id.value
  policy_id                    = newrelic_alert_policy.bitcoin-alerts.id
  type                         = "static"
  name                         = "BTC-RPC-Explorer-Cache is not running"
  enabled                      = true
  violation_time_limit_seconds = var.nrql-container-not-running.violation_time_limit_seconds
  value_function               = var.nrql-container-not-running.value_function

  fill_option = var.nrql-container-not-running.fill_option

  aggregation_window             = var.nrql-container-not-running.aggregation_window
  expiration_duration            = var.nrql-container-not-running.expiration_duration
  open_violation_on_expiration   = var.nrql-container-not-running.open_violation_on_expiration
  close_violations_on_expiration = var.nrql-container-not-running.close_violations_on_expiration

  nrql {
    query             = replace(var.nrql-container-not-running.query, "nrql-container-name", "btc-rpc-explorer-cache")
    evaluation_offset = 3
  }

  critical {
    operator              = var.nrql-container-not-running.operator
    threshold             = var.nrql-container-not-running.threshold
    threshold_duration    = 300
    threshold_occurrences = "ALL"
  }
}
