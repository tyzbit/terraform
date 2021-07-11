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

module "bitcoin-containers-not-running" {
  source     = "./modules/nrql-container-running"
  account_id = data.aws_ssm_parameter.account-id.value
  policy_id  = newrelic_alert_policy.bitcoin-alerts.id

  for_each = {
    electrumx              = { enabled = true, pretty_name = "Electrumx", container_count = 1 }
    bitcoin                = { enabled = true, pretty_name = "Bitcoin", container_count = 1 }
    btc-rpc-explorer       = { enabled = true, pretty_name = "BTC-RPC-Explorer", container_count = 1 }
    btc-rpc-explorer-cache = { enabled = true, pretty_name = "BTC-RPC-Explorer-Cache", container_count = 1 }
  }

  name    = "Not enough instances of ${each.value.pretty_name} running"
  enabled = each.value.enabled

  container_name  = each.key
  container_count = each.value.container_count
  providers = {
    newrelic = newrelic
  }
}

resource "newrelic_nrql_alert_condition" "electrumx-stale-file-handle" {
  account_id                   = data.aws_ssm_parameter.account-id.value
  policy_id                    = newrelic_alert_policy.bitcoin-alerts.id
  type                         = "static"
  name                         = "ElectrumX Restarted"
  enabled                      = true
  violation_time_limit_seconds = 604800
  value_function               = "single_value"

  fill_option = "none"

  aggregation_window             = 60
  expiration_duration            = 120
  open_violation_on_expiration   = false
  close_violations_on_expiration = false

  nrql {
    query             = <<EOF
      FROM Log
      SELECT count(timestamp)
      WHERE container_name = 'electrumx'
        AND message LIKE '%stale file handle%'
      EOF
    evaluation_offset = 3
  }

  critical {
    operator              = "above"
    threshold             = 0
    threshold_duration    = 120
    threshold_occurrences = "at_least_once"
  }
}

resource "newrelic_nrql_alert_condition" "electrumx-daemon-connection-problem" {
  account_id                   = data.aws_ssm_parameter.account-id.value
  policy_id                    = newrelic_alert_policy.bitcoin-alerts.id
  type                         = "static"
  name                         = "ElectrumX Daemon Connection Problem"
  enabled                      = true
  violation_time_limit_seconds = 604800
  value_function               = "single_value"

  fill_option = "none"

  aggregation_window             = 60
  expiration_duration            = 120
  open_violation_on_expiration   = false
  close_violations_on_expiration = false

  nrql {
    query             = <<EOF
      FROM Log
      SELECT count(*)
      WHERE container_name = 'electrumx'
      AND message LIKE '%Daemon:connection problem%'
      FACET host
      EOF
    evaluation_offset = 3
  }

  critical {
    operator              = "above"
    threshold             = 0
    threshold_duration    = 120
    threshold_occurrences = "ALL"
  }
}
