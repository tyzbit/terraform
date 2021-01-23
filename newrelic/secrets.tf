data "aws_ssm_parameter" "account-id" {
   name = "/global/atlantis/newrelic-account-id"
}