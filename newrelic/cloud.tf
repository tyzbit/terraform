resource "newrelic_synthetics_monitor" "qtosw" {
  name      = "QTOSW"
  type      = "SIMPLE"
  frequency = 10
  status    = "ENABLED"
  locations = ["AWS_US_EAST_1"]

  uri               = "https://qtosw.com"
  validation_string = "Witty"
  verify_ssl        = true
}

resource "newrelic_synthetics_alert_condition" "qtosw" {
  policy_id = newrelic_alert_policy.web-checks.id

  name       = "QTOSW Web Alert Policy"
  monitor_id = data.newrelic_synthetics_monitor.qtosw.id
}