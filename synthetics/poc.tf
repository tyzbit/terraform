resource "newrelic_synthetics_monitor" "qtosw-poc" {
  name = "QTOSW Terraform POC"
  type = "SIMPLE"
  frequency = 15
  status = "ENABLED"
  locations = ["AWS_US_EAST_1"]

  uri                       = "https://qtosw.com"                 # Required for type "SIMPLE" and "BROWSER"
  validation_string         = "Witty"                             # Optional for type "SIMPLE" and "BROWSER"
  verify_ssl                = true                                # Optional for type "SIMPLE" and "BROWSER"
}
