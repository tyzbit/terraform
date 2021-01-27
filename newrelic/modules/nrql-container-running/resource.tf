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
  expiration_duration            = 900
  open_violation_on_expiration   = false
  close_violations_on_expiration = false

  nrql {
    query = replace(<<EOF
      FROM K8sContainerSample,ContainerSample
      SELECT uniqueCount(status)
      WHERE (entityName LIKE '%container-name%')
        OR (containerName LIKE '%container-name%')
        AND (status LIKE '%Up%' OR status LIKE '%Running%')
      FACET hostname
    EOF
    , "container-name", var.container_name)
    evaluation_offset = 3
  }

  critical {
    operator              = "equals"
    threshold             = 0
    threshold_duration    = 300
    threshold_occurrences = "ALL"
  }
}
