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

module "media-containers-not-running" {
  source     = "./modules/nrql-container-running"
  account_id = data.aws_ssm_parameter.account-id.value
  policy_id  = newrelic_alert_policy.server-alerts.id

  for_each = {
    Nginx          = { enabled = true, pretty_name = "NGINX" }
    nextcloudcache = { enabled = true, pretty_name = "NextCloudCache" }
    NextCloudDB    = { enabled = true, pretty_name = "NextCloudDB" }
    NextCloud      = { enabled = true, pretty_name = "NextCloud" }
    motioneye      = { enabled = true, pretty_name = "MotionEye" }
    motion         = { enabled = true, pretty_name = "Motion" }
    SickChill      = { enabled = true, pretty_name = "SickChill" }
    Deluge         = { enabled = true, pretty_name = "Deluge" }
    plex           = { enabled = true, pretty_name = "PleX" }
  }

  name    = "${each.value.pretty_name} is not running"
  enabled = each.value.enabled

  container_name = each.key
  providers = {
    newrelic = newrelic
  }
}

resource "newrelic_nrql_alert_condition" "rars-found-in-downloads" {
  account_id                   = data.aws_ssm_parameter.account-id.value
  policy_id                    = newrelic_alert_policy.media-alerts.id
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
