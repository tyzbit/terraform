resource "newrelic_alert_policy" "server-alerts" {
  name                = "Server Alerts"
  incident_preference = "PER_CONDITION_AND_TARGET" # PER_POLICY is default
}

resource "newrelic_alert_policy_channel" "server-alerts" {
  policy_id = newrelic_alert_policy.bitcoin-alerts.id
  channel_ids = [
    newrelic_alert_channel.email-channel.id,
    newrelic_alert_channel.slack-channel.id
  ]
}

resource "newrelic_nrql_alert_condition" "high-disk-usage" {
  account_id                   = data.aws_ssm_parameter.account-id.value
  policy_id                    = newrelic_alert_policy.server-alerts.id
  type                         = "static"
  name                         = "Disk usage is high"
  enabled                      = true
  violation_time_limit_seconds = 3600
  value_function               = "single_value"

  fill_option = "none"

  aggregation_window             = 60
  expiration_duration            = 120
  open_violation_on_expiration   = false
  close_violations_on_expiration = false

  nrql {
    query             = <<EOF
      FROM StorageSample
      SELECT average(diskUsedPercent)
      FACET hostname,mountPoint 
      EOF
    evaluation_offset = 3
  }

  critical {
    operator              = "above"
    threshold             = 90
    threshold_duration    = 300
    threshold_occurrences = "ALL"
  }
}

resource "newrelic_nrql_alert_condition" "high-memory-usage" {
  account_id                   = data.aws_ssm_parameter.account-id.value
  policy_id                    = newrelic_alert_policy.server-alerts.id
  type                         = "static"
  name                         = "Memory usage is high"
  enabled                      = true
  violation_time_limit_seconds = 3600
  value_function               = "single_value"

  fill_option = "none"

  aggregation_window             = 60
  expiration_duration            = 120
  open_violation_on_expiration   = false
  close_violations_on_expiration = false

  nrql {
    query             = <<EOF
      FROM SystemSample
      SELECT average(memoryUsedPercent)
      FACET hostname
      EOF
    evaluation_offset = 3
  }

  critical {
    operator              = "above"
    threshold             = 90
    threshold_duration    = 900
    threshold_occurrences = "ALL"
  }
}

resource "newrelic_nrql_alert_condition" "high-cpu-usage" {
  account_id                   = data.aws_ssm_parameter.account-id.value
  policy_id                    = newrelic_alert_policy.server-alerts.id
  type                         = "static"
  name                         = "CPU pegged above 90"
  enabled                      = true
  violation_time_limit_seconds = 3600
  value_function               = "single_value"

  fill_option = "none"

  aggregation_window             = 60
  expiration_duration            = 120
  open_violation_on_expiration   = false
  close_violations_on_expiration = false

  nrql {
    query             = <<EOF
      FROM SystemSample
      SELECT average(cpuPercent)
      FACET hostname 
      EOF
    evaluation_offset = 3
  }

  critical {
    operator              = "above"
    threshold             = 90
    threshold_duration    = 1800
    threshold_occurrences = "ALL"
  }
}
