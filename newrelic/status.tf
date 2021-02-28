locals {
  when = "24 hours ago"
  monitored_containers = toset([
    "bitcoin",
    "btc-rpc-explorer",
    "btc-rpc-explorer-cache",
    "plex",
    "NextCloud",
    "NextCloudCache",
    "NextCloudDB",
    "electrumx",
    "Nginx",
    "Deluge",
    "SickChill",
    "motion",
    "motioneye",
  ])
  container_uptime_where_clause = join(" OR ",
    [
      for container in local.monitored_containers :
      replace("(name OR displayName) = 'container-name'", "container-name", container)
    ]
  )
  log_error_messages = toset([
    "error",
    "warn",
    "excep",
    "stack",
    "fail",
    "prob",
  ])
  log_error_where_clause = join(" OR ",
    [
      for message in local.log_error_messages :
      replace("message LIKE '%replacement%'", "replacement", message)
    ]
  )
}

resource "newrelic_one_dashboard" "status-page" {
  name        = "Status page"
  permissions = "public_read_only"

  page {
    name = "Status page"

    widget_bar {
      title  = "Container Uptime"
      row    = 1
      column = 1
      width  = 2
      height = 7

      nrql_query {
        account_id = data.aws_ssm_parameter.account-id.value
        query      = <<EOF
          FROM K8sContainerSample,ContainerSample 
          SELECT percentage(count(timestamp), WHERE status LIKE '%up%' OR status LIKE '%running%') as 'Running' 
          WHERE ${local.container_uptime_where_clause}
          FACET (name or displayName) 
          SINCE ${local.when}
          LIMIT MAX
        EOF
      }
    }

    widget_bar {
      title  = "Frontend Uptime"
      row    = 1
      column = 3
      width  = 2
      height = 7

      nrql_query {
        account_id = data.aws_ssm_parameter.account-id.value
        query      = <<EOF
          FROM SyntheticCheck
          SELECT percentage(count(*), WHERE error IS NULL)
          FACET monitorName
          SINCE ${local.when}
          LIMIT MAX
        EOF
      }
    }
    widget_area {
      title  = "Errors per minute"
      row    = 1
      column = 5
      width  = 4
      height = 4

      nrql_query {
        account_id = data.aws_ssm_parameter.account-id.value
        query      = <<EOF
          FROM Log
          SELECT count(*)
          WHERE ${local.log_error_where_clause}
          TIMESERIES
          SINCE ${local.when}
          LIMIT MAX
        EOF
      }
    }
  }
}
