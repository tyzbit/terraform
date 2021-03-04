resource "newrelic_synthetics_monitor" "monitor" {
  name      = var.name
  type      = "SIMPLE"
  frequency = 10
  status    = var.enabled == true ? "ENABLED" : "DISABLED"
  locations = ["AWS_US_EAST_1"]

  uri               = var.uri
  validation_string = var.validation_string
  verify_ssl        = var.verify_ssl
}

resource "newrelic_synthetics_alert_condition" "monitor" {
  policy_id = var.policy_id

  name       = "${var.name} Web Alert Policy"
  monitor_id = newrelic_synthetics_monitor.monitor.id
}
