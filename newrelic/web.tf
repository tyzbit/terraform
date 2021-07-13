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

resource "newrelic_alert_policy" "web-checks-slack" {
  name                = "Web Checks Slack"
  incident_preference = "PER_CONDITION_AND_TARGET" # PER_POLICY is default
}

resource "newrelic_alert_policy_channel" "web-alerts-slack" {
  policy_id = newrelic_alert_policy.web-checks-slack.id
  channel_ids = [
    newrelic_alert_channel.slack-channel.id
  ]
}

resource "newrelic_alert_policy" "statuspage-qtosw-web-checks" {
  name                = "Statuspage - qtosw"
  incident_preference = "PER_CONDITION_AND_TARGET" # PER_POLICY is default
}

resource "newrelic_alert_policy_channel" "statuspage-qtosw-web-alerts" {
  policy_id = newrelic_alert_policy.statuspage-qtosw-web-checks.id
  channel_ids = [
    newrelic_alert_channel.statuspage-qtosw-email.id,
    newrelic_alert_channel.pagerduty.id,
    newrelic_alert_channel.slack-channel.id
  ]
}

resource "newrelic_alert_policy" "statuspage-primary-plex-web-checks" {
  name                = "Statuspage - Primary Plex"
  incident_preference = "PER_CONDITION_AND_TARGET" # PER_POLICY is default
}

resource "newrelic_alert_policy_channel" "statuspage-primary-plex-web-alerts" {
  policy_id = newrelic_alert_policy.statuspage-primary-plex-web-checks.id
  channel_ids = [
    newrelic_alert_channel.statuspage-primary-plex-email.id,
    newrelic_alert_channel.pagerduty.id,
    newrelic_alert_channel.slack-channel.id
  ]
}

resource "newrelic_alert_policy" "statuspage-secondary-plex-web-checks" {
  name                = "Statuspage - Secondary Plex"
  incident_preference = "PER_CONDITION_AND_TARGET" # PER_POLICY is default
}

resource "newrelic_alert_policy_channel" "statuspage-secondary-plex-web-alerts" {
  policy_id = newrelic_alert_policy.statuspage-secondary-plex-web-checks.id
  channel_ids = [
    newrelic_alert_channel.statuspage-secondary-plex-email.id,
    newrelic_alert_channel.pagerduty.id,
    newrelic_alert_channel.slack-channel.id
  ]
}

module "general-web-checks" {
  source = "./modules/simple-synthetics-monitor"

  for_each = {
    btc = {
      name              = "BTC-RPC-Explorer",
      enabled           = true,
      verify_ssl        = false,
      uri               = "https://btc.qtosw.com",
      validation_string = "btc-rpc-explorer",
      policy_id         = newrelic_alert_policy.web-checks.id
    }

    cloud = {
      name              = "NextCloud",
      enabled           = true,
      verify_ssl        = false,
      uri               = "https://cloud.qtosw.com",
      validation_string = "Nextcloud",
      policy_id         = newrelic_alert_policy.web-checks.id
    }

    files = {
      name              = "Files",
      enabled           = true,
      verify_ssl        = false,
      uri               = "https://files.qtosw.com",
      validation_string = "File Browser",
      policy_id         = newrelic_alert_policy.web-checks-slack.id
    }

    plex-1 = {
      name              = "Plex Primary",
      enabled           = true,
      verify_ssl        = false,
      uri               = "https://plex.qtosw.com:32400/web/index.html",
      validation_string = "plex",
      policy_id         = newrelic_alert_policy.statuspage-primary-plex-web-checks.id
    }

    plex-2 = {
      name              = "Plex Backup",
      enabled           = true,
      verify_ssl        = false,
      uri               = "https://plex-backup.qtosw.com/web/index.html",
      validation_string = "plex",
      policy_id         = newrelic_alert_policy.statuspage-secondary-plex-web-checks.id
    }

    qtosw = {
      name              = "QTOSW",
      enabled           = true,
      verify_ssl        = true,
      uri               = "https://qtosw.com",
      validation_string = "Witty",
      policy_id         = newrelic_alert_policy.statuspage-qtosw-web-checks.id
    }

    rancher = {
      name              = "Rancher",
      enabled           = true,
      verify_ssl        = false,
      uri               = "https://rancher.qtosw.com",
      validation_string = "Loading",
      policy_id         = newrelic_alert_policy.web-checks.id
    }

    torrent = {
      name              = "Torrent",
      enabled           = true,
      verify_ssl        = true,
      uri               = "https://torrent.qtosw.com",
      validation_string = "WebUI",
      policy_id         = newrelic_alert_policy.web-checks.id
    }
  }

  name    = each.value.name
  enabled = each.value.enabled

  uri               = each.value.uri
  validation_string = each.value.validation_string
  verify_ssl        = each.value.verify_ssl

  policy_id = each.value.policy_id

  providers = {
    newrelic = newrelic
  }
}
