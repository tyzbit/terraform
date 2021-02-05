resource "pagerduty_escalation_policy" "default-escalations" {
  name        = "Default"
  description = "Default severity escalation policy"
  num_loops   = 2

  rule {
    escalation_delay_in_minutes = 30

    target {
      type = "user_reference"
      id   = pagerduty_user.tyzbit.id
    }
  }
}

resource "pagerduty_service" "newrelic" {
  name                    = "Alerts from NewRelic"
  auto_resolve_timeout    = 14400
  acknowledgement_timeout = "null"
  escalation_policy       = pagerduty_escalation_policy.default-escalations.id
  alert_creation          = "create_alerts_and_incidents"
}

resource "pagerduty_ruleset" "default" {
  name = "Primary"
  team {
    id = pagerduty_team.qtosw-administrators.id
  }
}

# resource "pagerduty_event_rule" "default-event-rule-1" {
#   action_json = jsonencode([
#     [
#       "route",
#       pagerduty_service.newrelic.id
#     ],
#     [
#       "severity",
#       "critical"
#     ],
#     [
#       "annotate",
#       "Managed by Terraform"
#     ]
#   ])
#   condition_json = jsonencode([
#     "and",
#     ["exists", ["path", "details"], ""]
#   ])
# }
