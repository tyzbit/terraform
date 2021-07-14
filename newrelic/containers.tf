resource "newrelic_alert_policy" "container-alerts" {
  name                = "Container Alerts"
  incident_preference = "PER_CONDITION_AND_TARGET" # PER_POLICY is default
}

resource "newrelic_alert_policy_channel" "container-alerts" {
  policy_id = newrelic_alert_policy.container-alerts.id
  channel_ids = [
    #newrelic_alert_channel.email-channel.id,
    newrelic_alert_channel.pagerduty.id,
    newrelic_alert_channel.slack-channel.id
  ]
}

resource "newrelic_alert_policy" "container-alerts-slack" {
  name                = "Container Alerts Slack"
  incident_preference = "PER_CONDITION_AND_TARGET" # PER_POLICY is default
}

resource "newrelic_alert_policy_channel" "container-alerts-slack" {
  policy_id = newrelic_alert_policy.container-alerts-slack.id
  channel_ids = [
    newrelic_alert_channel.slack-channel.id
  ]
}

resource "newrelic_nrql_alert_condition" "container-oom" {
  account_id                   = data.aws_ssm_parameter.account-id.value
  policy_id                    = newrelic_alert_policy.container-alerts-slack.id
  type                         = "static"
  name                         = "Container OOMKilled"
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
      FROM K8sContainerSample
      SELECT count(*)
      WHERE reason ='OOMKilled'
      FACET containerName
      EOF
    evaluation_offset = 3
  }

  critical {
    operator              = "above"
    threshold             = 0
    threshold_duration    = 300
    threshold_occurrences = "at_least_once"
  }
}

resource "newrelic_nrql_alert_condition" "flux-reconcile-error" {
  account_id                   = data.aws_ssm_parameter.account-id.value
  policy_id                    = newrelic_alert_policy.container-alerts-slack.id
  type                         = "static"
  name                         = "Flux Error Reconciling"
  enabled                      = true
  violation_time_limit_seconds = 3600
  value_function               = "single_value"

  fill_option = "none"

  aggregation_window             = 60
  expiration_duration            = 3600
  open_violation_on_expiration   = false
  close_violations_on_expiration = false

  nrql {
    query             = <<EOF
      FROM Log
      SELECT count(*)
      WHERE namespace_name = 'flux-system'
      AND message LIKE '%Reconciler error%' 
      EOF
    evaluation_offset = 3
  }

  critical {
    operator              = "above"
    threshold             = 0
    threshold_duration    = 300
    threshold_occurrences = "ALL"
  }
}

resource "newrelic_nrql_alert_condition" "python-bus-error" {
  account_id                   = data.aws_ssm_parameter.account-id.value
  policy_id                    = newrelic_alert_policy.container-alerts-slack.id
  type                         = "static"
  name                         = "Frigate Python bus error"
  enabled                      = true
  violation_time_limit_seconds = 3600
  value_function               = "single_value"

  fill_option = "none"

  aggregation_window             = 60
  expiration_duration            = 3600
  open_violation_on_expiration   = false
  close_violations_on_expiration = false

  nrql {
    query             = <<EOF
      FROM Log
      SELECT count(*)
      WHERE container_name = 'frigate'
      AND message LIKE '%Fatal Python error: Bus error%' 
      EOF
    evaluation_offset = 3
  }

  critical {
    operator              = "above"
    threshold             = 0
    threshold_duration    = 300
    threshold_occurrences = "at_least_once"
  }
}

resource "newrelic_nrql_alert_condition" "failed-replica" {
  account_id                   = data.aws_ssm_parameter.account-id.value
  policy_id                    = newrelic_alert_policy.container-alerts-slack.id
  type                         = "static"
  name                         = "Failed Longhorn replica"
  enabled                      = true
  violation_time_limit_seconds = 3600
  value_function               = "single_value"

  fill_option = "none"

  aggregation_window             = 60
  expiration_duration            = 600
  open_violation_on_expiration   = false
  close_violations_on_expiration = false

  nrql {
    query             = <<EOF
      FROM Log
      SELECT count(timestamp)
      WHERE message LIKE '%failed replica%'
      EOF
    evaluation_offset = 3
  }

  critical {
    operator              = "above"
    threshold             = 0
    threshold_duration    = 300
    threshold_occurrences = "at_least_once"
  }
}
