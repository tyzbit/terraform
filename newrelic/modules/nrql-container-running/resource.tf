resource "newrelic_nrql_alert_condition" "container-running" {
  account_id                   = var.account_id
  policy_id                    = var.policy_id
  type                         = "static"
  name                         = var.name
  enabled                      = var.enabled
  violation_time_limit_seconds = 604800
  value_function               = "single_value"

  fill_option = "none"

  aggregation_window             = 60
  expiration_duration            = 86400
  open_violation_on_expiration   = false
  close_violations_on_expiration = false

  nrql {
    query = replace(<<EOF
      FROM K8sContainerSample,ContainerSample
      SELECT filter(uniquecount(hostname), WHERE status LIKE '%up%' OR status LIKE '%running%') as 'Running'
      WHERE (name OR displayName) = 'container-name'
    EOF
    , "container-name", var.container_name)
    evaluation_offset = 3
  }

  critical {
    operator              = "below"
    threshold             = var.container_count
    threshold_duration    = 300
    threshold_occurrences = "ALL"
  }
}
