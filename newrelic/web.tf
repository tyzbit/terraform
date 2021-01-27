resource "newrelic_alert_policy" "web-checks" {
  name                = "Web Checks"
  incident_preference = "PER_CONDITION_AND_TARGET" # PER_POLICY is default
}

resource "newrelic_alert_policy_channel" "web-alerts" {
  policy_id = newrelic_alert_policy.web-checks.id
  channel_ids = [
    #newrelic_alert_channel.email-channel.id,
    newrelic_alert_channel.pagerduty.id,
    newrelic_alert_channel.slack-channel.id
  ]
}

module "general-web-checks" {
  source     = "./modules/synthetics-monitor"
  account_id = data.aws_ssm_parameter.account-id.value
  policy_id  = newrelic_alert_policy.server-alerts.id

  for_each = {
    qtosw   = { name = "QTOSW", enabled = true, uri = "https://qtosw.com", validation_string = "Witty" }
    torrent = { name = "Torrent", enabled = true, uri = "https://torrent.qtosw.com", validation_string = "WebUI" }
    rancher = { name = "Rancher", enabled = true, uri = "https://rancher.qtosw.com", validation_string = "Loading" }
    cloud   = { name = "NextCloud", enabled = true, uri = "https://cloud.qtosw.com", validation_string = "Nextcloud" }
    plex    = { name = "Plex", enabled = true, uri = "https://plex.qtosw.com/web/index.html", validation_string = "plex" }
    bc      = { name = "BC", enabled = true, uri = "https://bc.qtosw.com", validation_string = "server is up" }
  }

  name    = each.value.name
  enabled = each.value.enabled

  uri               = each.value.uri
  validation_string = each.value.validation_string
  verify_ssl        = true

  providers = {
    newrelic = newrelic
  }
}
