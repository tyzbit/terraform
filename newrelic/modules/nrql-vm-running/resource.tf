resource "newrelic_nrql_alert_condition" "running-vms" {
  account_id                   = var.account_id
  policy_id                    = var.policy_id
  type                         = "static"
  name                         = var.name
  enabled                      = var.enabled
  violation_time_limit_seconds = 604800
  value_function               = "single_value"

  fill_option = "none"

  aggregation_window = 60

  nrql {
    query = replace(<<EOF
      FROM Log
      SELECT uniqueCount(running_vms)
      WHERE (running_vms LIKE '%vm-name%')
      FACET hostname
    EOF
    , "vm-name", var.vm_name)
    evaluation_offset = 3
  }

  critical {
    operator              = "equals"
    threshold             = 0
    threshold_duration    = 300
    threshold_occurrences = "ALL"
  }
}
