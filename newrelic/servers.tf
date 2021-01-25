resource "newrelic_alert_policy" "server-alerts" {
  name                = "Server Alerts"
  incident_preference = "PER_CONDITION_AND_TARGET" # PER_POLICY is default
}

resource "newrelic_alert_policy_channel" "server-alerts" {
  policy_id = newrelic_alert_policy.server-alerts.id
  channel_ids = [
    #newrelic_alert_channel.email-channel.id,
    newrelic_alert_channel.pagerduty.id,
    newrelic_alert_channel.slack-channel.id
  ]
}

resource "newrelic_nrql_alert_condition" "high-disk-usage" {
  account_id                   = data.aws_ssm_parameter.account-id.value
  policy_id                    = newrelic_alert_policy.server-alerts.id
  type                         = "static"
  name                         = "Disk usage is high"
  enabled                      = true
  violation_time_limit_seconds = var.nrql-system-metric-average.violation_time_limit_seconds
  value_function               = var.nrql-system-metric-average.value_function

  fill_option = var.nrql-system-metric-average.fill_option

  aggregation_window             = var.nrql-system-metric-average.aggregation_window
  expiration_duration            = var.nrql-system-metric-average.expiration_duration
  open_violation_on_expiration   = var.nrql-system-metric-average.open_violation_on_expiration
  close_violations_on_expiration = var.nrql-system-metric-average.close_violations_on_expiration

  nrql {
    query             = replace(var.nrql-system-metric-average.query, "metric", "diskUsedPercent")
    evaluation_offset = var.nrql-system-metric-average.evaluation_offset
  }

  critical {
    operator              = var.nrql-system-metric-average.operator
    threshold             = var.nrql-system-metric-average.threshold
    threshold_duration    = var.nrql-system-metric-average.threshold_duration
    threshold_occurrences = var.nrql-system-metric-average.threshold_occurrences
  }
}

resource "newrelic_nrql_alert_condition" "high-memory-usage" {
  account_id                   = data.aws_ssm_parameter.account-id.value
  policy_id                    = newrelic_alert_policy.server-alerts.id
  type                         = "static"
  name                         = "Memory usage is high"
  enabled                      = true
  violation_time_limit_seconds = var.nrql-system-metric-average.violation_time_limit_seconds
  value_function               = var.nrql-system-metric-average.value_function

  fill_option = var.nrql-system-metric-average.fill_option

  aggregation_window             = var.nrql-system-metric-average.aggregation_window
  expiration_duration            = var.nrql-system-metric-average.expiration_duration
  open_violation_on_expiration   = var.nrql-system-metric-average.open_violation_on_expiration
  close_violations_on_expiration = var.nrql-system-metric-average.close_violations_on_expiration

  nrql {
    query             = replace(var.nrql-system-metric-average.query, "metric", "memoryUsedPercent")
    evaluation_offset = 3
  }

  critical {
    operator              = var.nrql-system-metric-average.operator
    threshold             = var.nrql-system-metric-average.threshold
    threshold_duration    = var.nrql-system-metric-average.threshold_duration
    threshold_occurrences = var.nrql-system-metric-average.threshold_occurrences
  }
}

resource "newrelic_nrql_alert_condition" "high-cpu-usage" {
  account_id                   = data.aws_ssm_parameter.account-id.value
  policy_id                    = newrelic_alert_policy.server-alerts.id
  type                         = "static"
  name                         = "CPU pegged above 90"
  enabled                      = true
  violation_time_limit_seconds = var.nrql-system-metric-average.violation_time_limit_seconds
  value_function               = var.nrql-system-metric-average.value_function

  fill_option = var.nrql-system-metric-average.fill_option

  aggregation_window             = var.nrql-system-metric-average.aggregation_window
  expiration_duration            = var.nrql-system-metric-average.expiration_duration
  open_violation_on_expiration   = var.nrql-system-metric-average.open_violation_on_expiration
  close_violations_on_expiration = var.nrql-system-metric-average.close_violations_on_expiration

  nrql {
    query             = replace(var.nrql-system-metric-average.query, "metric", "cpuPercent")
    evaluation_offset = 3
  }

  critical {
    operator              = var.nrql-system-metric-average.operator
    threshold             = var.nrql-system-metric-average.threshold
    threshold_duration    = var.nrql-system-metric-average.threshold_duration
    threshold_occurrences = var.nrql-system-metric-average.threshold_occurrences
  }
}

resource "newrelic_nrql_alert_condition" "keymaster-not-running" {
  account_id                   = data.aws_ssm_parameter.account-id.value
  policy_id                    = newrelic_alert_policy.server-alerts.id
  type                         = "static"
  name                         = "Keymaster not running"
  enabled                      = true
  violation_time_limit_seconds = var.nrql-vm-not-running.violation_time_limit_seconds
  value_function               = var.nrql-vm-not-running.value_function

  fill_option = var.nrql-vm-not-running.fill_option

  aggregation_window             = var.nrql-vm-not-running.aggregation_window
  expiration_duration            = var.nrql-vm-not-running.expiration_duration
  open_violation_on_expiration   = var.nrql-vm-not-running.open_violation_on_expiration
  close_violations_on_expiration = var.nrql-vm-not-running.close_violations_on_expiration

  nrql {
    query             = replace(var.nrql-vm-not-running.query, "vm-name", "keymaster")
    evaluation_offset = 3
  }

  critical {
    operator              = var.nrql-vm-not-running.operator
    threshold             = var.nrql-vm-not-running.threshold
    threshold_duration    = var.nrql-vm-not-running.threshold_duration
    threshold_occurrences = var.nrql-vm-not-running.threshold_occurrences
  }
}

resource "newrelic_nrql_alert_condition" "foreman-not-running" {
  account_id                   = data.aws_ssm_parameter.account-id.value
  policy_id                    = newrelic_alert_policy.server-alerts.id
  type                         = "static"
  name                         = "Foreman not running"
  enabled                      = true
  violation_time_limit_seconds = var.nrql-vm-not-running.violation_time_limit_seconds
  value_function               = var.nrql-vm-not-running.value_function

  fill_option = var.nrql-vm-not-running.fill_option

  aggregation_window             = var.nrql-vm-not-running.aggregation_window
  expiration_duration            = var.nrql-vm-not-running.expiration_duration
  open_violation_on_expiration   = var.nrql-vm-not-running.open_violation_on_expiration
  close_violations_on_expiration = var.nrql-vm-not-running.close_violations_on_expiration

  nrql {
    query             = replace(var.nrql-vm-not-running.query, "vm-name", "foreman")
    evaluation_offset = 3
  }

  critical {
    operator              = var.nrql-vm-not-running.operator
    threshold             = var.nrql-vm-not-running.threshold
    threshold_duration    = var.nrql-vm-not-running.threshold_duration
    threshold_occurrences = var.nrql-vm-not-running.threshold_occurrences
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
