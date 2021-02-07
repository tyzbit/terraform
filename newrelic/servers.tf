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

module "system-metrics-above-90" {
  source     = "./modules/nrql-system-metric-nominal"
  account_id = data.aws_ssm_parameter.account-id.value
  policy_id  = newrelic_alert_policy.server-alerts.id

  for_each = {
    diskUsedPercent   = { enabled = true, pretty_name = "Disk" }
    memoryUsedPercent = { enabled = true, pretty_name = "Memory" }
    cpuUsedPercent    = { enabled = true, pretty_name = "CPU" }
  }

  name    = "${each.value.pretty_name} is high"
  enabled = each.value.enabled

  metric    = each.key
  operator  = "above"
  threshold = 90
}

resource "newrelic_nrql_alert_condition" "nfs-disk-above-90" {
  account_id                   = data.aws_ssm_parameter.account-id.value
  policy_id                    = newrelic_alert_policy.server-alerts.id
  type                         = "static"
  name                         = "NFS mount above 90 percent used"
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
      FROM NFSSample
      SELECT average(diskUsedPercent)
      FACET device
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

module "server-vms-not-running" {
  source     = "./modules/nrql-vm-running"
  account_id = data.aws_ssm_parameter.account-id.value
  policy_id  = newrelic_alert_policy.server-alerts.id

  for_each = {
    foreman   = { enabled = true }
    keymaster = { enabled = true }
  }

  name    = "${each.key} is not running"
  enabled = each.value.enabled

  vm_name = each.key
  providers = {
    newrelic = newrelic
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


module "server-port-checks" {
  source     = "./modules/nrql-port-open"
  account_id = data.aws_ssm_parameter.account-id.value
  policy_id  = newrelic_alert_policy.server-alerts.id

  for_each = {
    pizero = { enabled = true, job_comment = "Check that pizero SSH is open" },
    qtosw  = { enabled = true, job_comment = "Check that qtosw vpn is open" },
  }

  name    = "${each.value.job_comment} failed"
  enabled = each.value.enabled

  job_comment = each.value.job_comment
}

resource "newrelic_nrql_alert_condition" "system-temp-above-90" {
  account_id                   = data.aws_ssm_parameter.account-id.value
  policy_id                    = newrelic_alert_policy.server-alerts.id
  type                         = "static"
  name                         = "System temperature above 90"
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
      SELECT average(sensor_temperature_c)
      WHERE job_comment = 'Check the hardware temperature'
      FACET host
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

resource "newrelic_nrql_alert_condition" "k8s-volume-full-in-24-hours" {
  account_id                   = data.aws_ssm_parameter.account-id.value
  policy_id                    = newrelic_alert_policy.server-alerts.id
  type                         = "static"
  name                         = "K8S volume will fill up in less than a day"
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
      FROM K8sVolumeSample
      SELECT predictLinear(fsUsedPercent, 24 hours)
      WHERE volumeName NOT LIKE '%default-token%' 
      FACET volumeName
      SINCE 1 hour ago
      EOF
    evaluation_offset = 3
  }

  critical {
    operator              = "above"
    threshold             = 100
    threshold_duration    = 900
    threshold_occurrences = "ALL"
  }
}
