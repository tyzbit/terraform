resource "newrelic_alert_policy" "server-alerts" {
  name                = "Server Alerts"
  incident_preference = "PER_CONDITION_AND_TARGET" # PER_POLICY is default
}

resource "newrelic_alert_policy_channel" "server-alerts" {
  policy_id = newrelic_alert_policy.server-alerts.id
  channel_ids = [
    #newrelic_alert_channel.email-channel.id,
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
    query             = replace(var.nrql-system-metric-average, "metric", "memoryUsedPercent")
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
    query             = replace(var.nrql-system-metric-average, "metric", "cpuPercent")
    evaluation_offset = 3
  }

  critical {
    operator              = "above"
    threshold             = 90
    threshold_duration    = 1800
    threshold_occurrences = "ALL"
  }
}

resource "newrelic_nrql_alert_condition" "local-ip-change" {
  account_id                   = data.aws_ssm_parameter.account-id.value
  policy_id                    = newrelic_alert_policy.server-alerts.id
  type                         = "static"
  name                         = "Local IP has changed"
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
      SELECT count(*)
      WHERE job_comment = 'Check my IP'
      FACET ip  
      EOF
    evaluation_offset = 3
  }

  critical {
    operator              = "equals"
    threshold             = 0
    threshold_duration    = 3600
    threshold_occurrences = "ALL"
  }
}
