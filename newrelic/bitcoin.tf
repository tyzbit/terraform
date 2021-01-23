resource "newrelic_alert_policy" "bitcoin-alerts" {
  name                = "Bitcoin Alerts"
  incident_preference = "PER_CONDITION_AND_TARGET" # PER_POLICY is default
}

resource "newrelic_nrql_alert_condition" "foo" {
  account_id                   = data.aws_ssm_parameter.account-id.value
  policy_id                    = newrelic_alert_policy.bitcoin-alerts.id
  type                         = "static"
  name                         = "Electrumx is not running"
  enabled                      = true
  violation_time_limit_seconds = 3600
  value_function               = "single_value"

  fill_option          = "none"

  aggregation_window             = 60
  expiration_duration            = 120
  open_violation_on_expiration   = false
  close_violations_on_expiration = false

  nrql {
    query             = <<EOF
      FROM K8sContainerSample,ContainerSample
      SELECT uniqueCount(entityName)
      WHERE (entityName LIKE '%electrumx%') OR (containerName LIKE '%electrumx%')
      FACET hostname
      EOF
    evaluation_offset = 3
  }

  critical {
    operator              = "below"
    threshold             = 5.5
    threshold_duration    = 300
    threshold_occurrences = "ALL"
  }
}