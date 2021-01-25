resource "aws_ssm_parameter" "pagerduty-integration-key" {
  name  = "/global/pagerduty/default-route-integration-key"
  type  = "SecureString"
  value = pagerduty_ruleset.default.routing_keys[0]
}
