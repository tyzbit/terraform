# resource "newrelic_alert_policy" "server-alerts" {
#   name                = "Server Alerts"
#   incident_preference = "PER_CONDITION_AND_TARGET" # PER_POLICY is default
# }