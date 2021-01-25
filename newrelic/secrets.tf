data "aws_ssm_parameter" "account-id" {
  name = "/global/atlantis/newrelic-account-id"
}

data "aws_ssm_parameter" "pagerduty-key" {
  name = "/global/pagerduty/integration-key"
}
