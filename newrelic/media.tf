# resource "newrelic_alert_policy" "media-alerts" {
#   name                = "Media Alerts"
#   incident_preference = "PER_CONDITION_AND_TARGET" # PER_POLICY is default
# }

# resource "newrelic_alert_policy_channel" "media-alerts" {
#   policy_id  = newrelic_alert_policy.bitcoin-alerts.id
#   channel_ids = [
#     newrelic_alert_channel.email-channel.id,
#     newrelic_alert_channel.slack-channel.id
#   ]
# }