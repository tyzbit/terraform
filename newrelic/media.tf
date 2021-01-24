resource "newrelic_alert_policy" "media-alerts" {
  name                = "Media Alerts"
  incident_preference = "PER_CONDITION_AND_TARGET" # PER_POLICY is default
}

resource "newrelic_alert_policy_channel" "media-alerts" {
  policy_id = newrelic_alert_policy.media-alerts.id
  channel_ids = [
    #newrelic_alert_channel.email-channel.id,
    newrelic_alert_channel.slack-channel.id
  ]
}

resource "newrelic_nrql_alert_condition" "nginx-not-running" {
  account_id                   = data.aws_ssm_parameter.account-id.value
  policy_id                    = newrelic_alert_policy.media-alerts.id
  type                         = "static"
  name                         = "NGINX is not running"
  enabled                      = true
  violation_time_limit_seconds = 3600
  value_function               = "single_value"

  fill_option = "none"

  aggregation_window             = 60
  expiration_duration            = 120
  open_violation_on_expiration   = false
  close_violations_on_expiration = false

  nrql {
    query             = replace(var.nrql-container-not-running, "nrql-container-name", "Nginx")
    evaluation_offset = 3
  }

  critical {
    operator              = "equals"
    threshold             = 0
    threshold_duration    = 300
    threshold_occurrences = "ALL"
  }
}

resource "newrelic_nrql_alert_condition" "nextcloudcache-not-running" {
  account_id                   = data.aws_ssm_parameter.account-id.value
  policy_id                    = newrelic_alert_policy.media-alerts.id
  type                         = "static"
  name                         = "NextCloudCache is not running"
  enabled                      = true
  violation_time_limit_seconds = 3600
  value_function               = "single_value"

  fill_option = "none"

  aggregation_window             = 60
  expiration_duration            = 120
  open_violation_on_expiration   = false
  close_violations_on_expiration = false

  nrql {
    query             = <<EOF
      FROM ContainerSample
      SELECT uniqueCount(entityName)
      WHERE entityName LIKE 'NextCloudCache'
      FACET host 
      EOF
    evaluation_offset = 3
  }

  critical {
    operator              = "equals"
    threshold             = 0
    threshold_duration    = 300
    threshold_occurrences = "ALL"
  }
}

resource "newrelic_nrql_alert_condition" "nextclouddb-not-running" {
  account_id                   = data.aws_ssm_parameter.account-id.value
  policy_id                    = newrelic_alert_policy.media-alerts.id
  type                         = "static"
  name                         = "NextCloudDB is not running"
  enabled                      = true
  violation_time_limit_seconds = 3600
  value_function               = "single_value"

  fill_option = "none"

  aggregation_window             = 60
  expiration_duration            = 120
  open_violation_on_expiration   = false
  close_violations_on_expiration = false

  nrql {
    query             = replace(var.nrql-container-not-running, "nrql-container-name", "NextCloudDB")
    evaluation_offset = 3
  }

  critical {
    operator              = "equals"
    threshold             = 0
    threshold_duration    = 300
    threshold_occurrences = "ALL"
  }
}

resource "newrelic_nrql_alert_condition" "nextcloud-not-running" {
  account_id                   = data.aws_ssm_parameter.account-id.value
  policy_id                    = newrelic_alert_policy.media-alerts.id
  type                         = "static"
  name                         = "NextCloud is not running"
  enabled                      = true
  violation_time_limit_seconds = 3600
  value_function               = "single_value"

  fill_option = "none"

  aggregation_window             = 60
  expiration_duration            = 120
  open_violation_on_expiration   = false
  close_violations_on_expiration = false

  nrql {
    query             = replace(var.nrql-container-not-running, "nrql-container-name", "NextCloud")
    evaluation_offset = 3
  }

  critical {
    operator              = "equals"
    threshold             = 0
    threshold_duration    = 300
    threshold_occurrences = "ALL"
  }
}

resource "newrelic_nrql_alert_condition" "motioneye-not-running" {
  account_id                   = data.aws_ssm_parameter.account-id.value
  policy_id                    = newrelic_alert_policy.media-alerts.id
  type                         = "static"
  name                         = "MotionEye is not running"
  enabled                      = true
  violation_time_limit_seconds = 3600
  value_function               = "single_value"

  fill_option = "none"

  aggregation_window             = 60
  expiration_duration            = 120
  open_violation_on_expiration   = false
  close_violations_on_expiration = false

  nrql {
    query             = replace(var.nrql-container-not-running, "nrql-container-name", "motioneye")
    evaluation_offset = 3
  }

  critical {
    operator              = "equals"
    threshold             = 0
    threshold_duration    = 300
    threshold_occurrences = "ALL"
  }
}

resource "newrelic_nrql_alert_condition" "motion-not-running" {
  account_id                   = data.aws_ssm_parameter.account-id.value
  policy_id                    = newrelic_alert_policy.media-alerts.id
  type                         = "static"
  name                         = "Motion is not running"
  enabled                      = true
  violation_time_limit_seconds = 3600
  value_function               = "single_value"

  fill_option = "none"

  aggregation_window             = 60
  expiration_duration            = 120
  open_violation_on_expiration   = false
  close_violations_on_expiration = false

  nrql {
    query             = replace(var.nrql-container-not-running, "nrql-container-name", "motion")
    evaluation_offset = 3
  }

  critical {
    operator              = "equals"
    threshold             = 0
    threshold_duration    = 300
    threshold_occurrences = "ALL"
  }
}

resource "newrelic_nrql_alert_condition" "sickchill-not-running" {
  account_id                   = data.aws_ssm_parameter.account-id.value
  policy_id                    = newrelic_alert_policy.media-alerts.id
  type                         = "static"
  name                         = "SickChill is not running"
  enabled                      = true
  violation_time_limit_seconds = 3600
  value_function               = "single_value"

  fill_option = "none"

  aggregation_window             = 60
  expiration_duration            = 120
  open_violation_on_expiration   = false
  close_violations_on_expiration = false

  nrql {
    query             = replace(var.nrql-container-not-running, "nrql-container-name", "SickChill")
    evaluation_offset = 3
  }

  critical {
    operator              = "equals"
    threshold             = 0
    threshold_duration    = 300
    threshold_occurrences = "ALL"
  }
}

resource "newrelic_nrql_alert_condition" "deluge-not-running" {
  account_id                   = data.aws_ssm_parameter.account-id.value
  policy_id                    = newrelic_alert_policy.media-alerts.id
  type                         = "static"
  name                         = "Deluge is not running"
  enabled                      = true
  violation_time_limit_seconds = 3600
  value_function               = "single_value"

  fill_option = "none"

  aggregation_window             = 60
  expiration_duration            = 120
  open_violation_on_expiration   = false
  close_violations_on_expiration = false

  nrql {
    query             = replace(var.nrql-container-not-running, "nrql-container-name", "Deluge")
    evaluation_offset = 3
  }

  critical {
    operator              = "equals"
    threshold             = 0
    threshold_duration    = 300
    threshold_occurrences = "ALL"
  }
}

resource "newrelic_nrql_alert_condition" "plex-not-running" {
  account_id                   = data.aws_ssm_parameter.account-id.value
  policy_id                    = newrelic_alert_policy.media-alerts.id
  type                         = "static"
  name                         = "Plex is not running"
  enabled                      = true
  violation_time_limit_seconds = 3600
  value_function               = "single_value"

  fill_option = "none"

  aggregation_window             = 60
  expiration_duration            = 120
  open_violation_on_expiration   = false
  close_violations_on_expiration = false

  nrql {
    query             = replace(var.nrql-container-not-running, "nrql-container-name", "plex")
    evaluation_offset = 3
  }

  critical {
    operator              = "equals"
    threshold             = 0
    threshold_duration    = 300
    threshold_occurrences = "ALL"
  }
}

resource "newrelic_nrql_alert_condition" "rars-found-in-downloads" {
  account_id                   = data.aws_ssm_parameter.account-id.value
  policy_id                    = newrelic_alert_policy.media-alerts.id
  type                         = "static"
  name                         = "RARs found in Downloads folder"
  enabled                      = true
  violation_time_limit_seconds = 3600
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
    threshold_duration    = 300
    threshold_occurrences = "ALL"
  }
}
