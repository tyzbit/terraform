variable "nrql-container-not-running" {
  type    = string
  default = <<EOF
    FROM K8sContainerSample,ContainerSample
    SELECT uniqueCount(status)
    WHERE (entityName LIKE '%container-name%')
      OR (containerName LIKE '%container-name%')
      AND (status LIKE '%Up%' OR status LIKE '%Running%')
    FACET hostname
  EOF
}

variable "nrql-system-metric-average" {
  type    = string
  default = <<EOF
    FROM SystemSample
    SELECT average(metric)
    FACET hostname
  EOF
}
