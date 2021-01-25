# resource "newrelic_one_dashboard" "logs" {
#   name = "Logs"

#   page {
#     name = "Logs"

#     widget_area {
#       title  = "Estimated Daily Log Volume"
#       row    = 1
#       column = 1

#       nrql_query {
#         account_id = data.aws_ssm_parameter.account-id.value
#         query      = <<EOF
#           SELECT rate(sum(GigabytesIngested), 1 day)
#           FROM NrConsumption
#           WHERE productLine='DataPlatform'
#           FACET usageMetric
#           TIMESERIES 1 hour since 5 days ago
#         EOF
#       }
#     }
#   }
# }
