resource "newrelic_alert_policy" "bitcoin-alerts" {
  name                = "Bitcoin Alerts"
  incident_preference = "PER_CONDITION_AND_TARGET" # PER_POLICY is default
}

resource "newrelic_alert_policy_channel" "bitcoin-alerts" {
  policy_id = newrelic_alert_policy.bitcoin-alerts.id
  channel_ids = [
    #newrelic_alert_channel.email-channel.id,
    newrelic_alert_channel.pagerduty.id,
    newrelic_alert_channel.slack-channel.id
  ]
}

module "bitcoin-containers-not-running" {
  source     = "./modules/nrql-container-running"
  account_id = data.aws_ssm_parameter.account-id.value
  policy_id  = newrelic_alert_policy.bitcoin-alerts.id

  for_each = {
    electrumx              = { enabled = true, pretty_name = "Electrumx" }
    bitcoin                = { enabled = true, pretty_name = "Bitcoin" }
    btc-rpc-explorer       = { enabled = true, pretty_name = "BTC-RPC-Explorer" }
    btc-rpc-explorer-cache = { enabled = true, pretty_name = "Electrumx" }
  }

  name    = "${each.value.pretty_name} is not running"
  enabled = each.value.enabled

  container_name = each.key
  providers = {
    newrelic = newrelic
  }
}
