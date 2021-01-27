resource "newrelic_nrql_alert_condition" "system" {
  account_id                   = var.account_id
  policy_id                    = var.policy_id
  type                         = "static"
  name                         = var.name
  enabled                      = var.enabled
  violation_time_limit_seconds = 604800
  value_function               = "single_value"

  fill_option = "none"

  aggregation_window             = 60
  expiration_duration            = 300
  open_violation_on_expiration   = false
  close_violations_on_expiration = false

  nrql {
    query = replace(<<EOF
      FROM SystemSample
      SELECT average(metric)
      FACET hostname
    EOF
    , "metric", var.metric)
    evaluation_offset = 3
  }

  critical {
    operator              = var.operator
    threshold             = var.threshold
    threshold_duration    = 300
    threshold_occurrences = "ALL"
  }
}
