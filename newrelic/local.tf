data "newrelic_synthetics_monitor" "torrent" {
  name = "Torrent"
  depends_on = [
    newrelic_synthetics_monitor.torrent
  ]
}

resource "newrelic_synthetics_monitor" "torrent" {
  name      = "Torrent"
  type      = "SIMPLE"
  frequency = 10
  status    = "ENABLED"
  locations = ["AWS_US_EAST_1"]

  uri               = "https://torrent.qtosw.com"
  validation_string = "WebUI"
  verify_ssl        = true
}

resource "newrelic_synthetics_alert_condition" "torrent" {
  policy_id = newrelic_alert_policy.web-checks.id

  name       = "Torrent Web Alert Policy"
  monitor_id = data.newrelic_synthetics_monitor.torrent.id
}

data "newrelic_synthetics_monitor" "rancher" {
  name = "Rancher"
  depends_on = [
    newrelic_synthetics_monitor.rancher
  ]
}

resource "newrelic_synthetics_monitor" "rancher" {
  name      = "Rancher"
  type      = "SIMPLE"
  frequency = 10
  status    = "ENABLED"
  locations = ["AWS_US_EAST_1"]

  uri               = "https://rancher.qtosw.com"
  validation_string = "Loading"
  verify_ssl        = true
}

resource "newrelic_synthetics_alert_condition" "rancher" {
  policy_id = newrelic_alert_policy.web-checks.id

  name       = "Rancher Web Alert Policy"
  monitor_id = data.newrelic_synthetics_monitor.rancher.id
}

data "newrelic_synthetics_monitor" "cloud" {
  name = "NextCloud"
  depends_on = [
    newrelic_synthetics_monitor.cloud
  ]
}

resource "newrelic_synthetics_monitor" "cloud" {
  name      = "NextCloud"
  type      = "SIMPLE"
  frequency = 10
  status    = "ENABLED"
  locations = ["AWS_US_EAST_1"]

  uri               = "https://cloud.qtosw.com"
  validation_string = "Nextcloud"
  verify_ssl        = true
}

resource "newrelic_synthetics_alert_condition" "cloud" {
  policy_id = newrelic_alert_policy.web-checks.id

  name       = "NextCloud Web Alert Policy"
  monitor_id = data.newrelic_synthetics_monitor.cloud.id
}

data "newrelic_synthetics_monitor" "plex" {
  name = "Plex"
  depends_on = [
    newrelic_synthetics_monitor.plex
  ]
}

resource "newrelic_synthetics_monitor" "plex" {
  name      = "Plex"
  type      = "SIMPLE"
  frequency = 10
  status    = "ENABLED"
  locations = ["AWS_US_EAST_1"]

  uri               = "https://plex.qtosw.com/web/index.html"
  validation_string = "plex"
  verify_ssl        = true
}

resource "newrelic_synthetics_alert_condition" "plex" {
  policy_id = newrelic_alert_policy.web-checks.id

  name       = "Plex Web Alert Policy"
  monitor_id = data.newrelic_synthetics_monitor.plex.id
}

data "newrelic_synthetics_monitor" "bc" {
  name = "BC"
  depends_on = [
    newrelic_synthetics_monitor.bc
  ]
}

resource "newrelic_synthetics_monitor" "bc" {
  name      = "BC"
  type      = "SIMPLE"
  frequency = 10
  status    = "ENABLED"
  locations = ["AWS_US_EAST_1"]

  uri               = "https://bc.qtosw.com"
  validation_string = "server is up"
  verify_ssl        = true
}

resource "newrelic_synthetics_alert_condition" "bc" {
  policy_id = newrelic_alert_policy.web-checks.id

  name       = "Plex Web Alert Policy"
  monitor_id = data.newrelic_synthetics_monitor.bc.id
}
