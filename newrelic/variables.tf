variable "nrql-container-not-running" {
  default = {
    aggregation_window             = 60
    close_violations_on_expiration = false
    evaluation_offset              = 3
    expiration_duration            = 120
    fill_option                    = "none"
    open_violation_on_expiration   = true
    operator                       = "equals"
    query                          = <<EOF
      FROM K8sContainerSample,ContainerSample
      SELECT uniqueCount(status)
      WHERE (entityName LIKE '%container-name%')
        OR (containerName LIKE '%container-name%')
        AND (status LIKE '%Up%' OR status LIKE '%Running%')
      FACET hostname
    EOF
    threshold                      = 0
    threshold_duration             = 300
    threshold_occurrences          = "ALL"
    value_function                 = "single_value"
    violation_time_limit_seconds   = 3600
  }
}

variable "nrql-system-metric-average" {
  default = {
    aggregation_window             = 60
    close_violations_on_expiration = false
    evaluation_offset              = 3
    expiration_duration            = 120
    fill_option                    = "none"
    open_violation_on_expiration   = false
    operator                       = "above"
    query                          = <<EOF
      FROM SystemSample
      SELECT average(metric)
      FACET hostname
    EOF
    threshold                      = 90
    threshold_duration             = 300
    threshold_occurrences          = "ALL"
    value_function                 = "single_value"
    violation_time_limit_seconds   = 3600
  }
}
