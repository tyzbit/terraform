resource "newrelic_nrql_alert_condition" "check-port" {
  account_id                   = var.account_id
  policy_id                    = var.policy_id
  type                         = "static"
  name                         = var.name
  enabled                      = var.enabled
  violation_time_limit_seconds = 604800
  value_function               = "single_value"

  fill_option = "none"

  aggregation_window             = 60
  expiration_duration            = 900
  open_violation_on_expiration   = false
  close_violations_on_expiration = false

  nrql {
    query = replace(<<EOF
      FROM Log
      SELECT count(*)
      WHERE job_comment = 'job-comment'
        AND port_open = 'false'
      EOF
    , "job-comment", var.job_comment)
    evaluation_offset = 3
  }

  critical {
    operator              = "above"
    threshold             = 0
    threshold_duration    = 300
    threshold_occurrences = "ALL"
  }
}
