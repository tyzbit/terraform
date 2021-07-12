resource "newrelic_alert_policy" "media-alerts" {
  name                = "Media Alerts"
  incident_preference = "PER_CONDITION_AND_TARGET" # PER_POLICY is default
}

resource "newrelic_alert_policy_channel" "media-alerts" {
  policy_id = newrelic_alert_policy.media-alerts.id
  channel_ids = [
    #newrelic_alert_channel.email-channel.id,
    newrelic_alert_channel.pagerduty.id,
    newrelic_alert_channel.slack-channel.id
  ]
}

resource "newrelic_alert_policy" "media-alerts-slack" {
  name                = "Media Alerts Slack"
  incident_preference = "PER_CONDITION_AND_TARGET" # PER_POLICY is default
}

resource "newrelic_alert_policy_channel" "media-alerts-slack" {
  policy_id = newrelic_alert_policy.media-alerts-slack.id
  channel_ids = [
    newrelic_alert_channel.slack-channel.id
  ]
}

module "media-containers-not-running" {
  source     = "./modules/nrql-container-running"
  account_id = data.aws_ssm_parameter.account-id.value
  policy_id  = newrelic_alert_policy.media-alerts.id

  for_each = {
    frigate          = { enabled = true, pretty_name = "Frigate", container_count = 1 }
    discord-archiver = { enabled = true, pretty_name = "Discord Archive.org bot", container_count = 1 }
    Nginx            = { enabled = true, pretty_name = "NGINX", container_count = 1 }
    nextcloud-cache  = { enabled = true, pretty_name = "NextCloudCache", container_count = 1 }
    nextcloud-db     = { enabled = true, pretty_name = "NextCloudDB", container_count = 1 }
    nextcloud        = { enabled = true, pretty_name = "NextCloud", container_count = 1 }
    motioneye        = { enabled = true, pretty_name = "MotionEye", container_count = 1 }
    SickChill        = { enabled = true, pretty_name = "SickChill", container_count = 1 }
    Deluge           = { enabled = true, pretty_name = "Deluge", container_count = 1 }
    plex             = { enabled = true, pretty_name = "PleX", container_count = 1 }
    plex-secondary   = { enabled = true, pretty_name = "PleX secondary", container_count = 1 }
    # motion-browser  = { enabled = true, pretty_name = "Motion", container_count = 1 }
  }

  name    = "Not enough instances of ${each.value.pretty_name} running"
  enabled = each.value.enabled

  container_name  = each.key
  container_count = each.value.container_count
  providers = {
    newrelic = newrelic
  }
}

resource "newrelic_nrql_alert_condition" "rars-found-in-downloads" {
  account_id                   = data.aws_ssm_parameter.account-id.value
  policy_id                    = newrelic_alert_policy.media-alerts-slack.id
  type                         = "static"
  name                         = "RARs found in Downloads folder"
  enabled                      = true
  violation_time_limit_seconds = 604800
  value_function               = "single_value"

  fill_option = "none"

  aggregation_window             = 60
  expiration_duration            = 120
  open_violation_on_expiration   = false
  close_violations_on_expiration = false

  nrql {
    query             = <<EOF
      FROM Log
      SELECT latest(files_found)
      WHERE job_comment = 'Count RARs in downloads folder'
      EOF
    evaluation_offset = 3
  }

  critical {
    operator              = "above"
    threshold             = 0
    threshold_duration    = 60
    threshold_occurrences = "at_least_once"
  }
}
