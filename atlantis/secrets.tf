resource "aws_ssm_parameter" "aws-access-key" {
  name  = "/global/atlantis/aws-access-key"
  type  = "SecureString"
  value = ""

  tags = local.default_tags

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "aws-secret-key" {
  name  = "/global/atlantis/aws-secret-key"
  type  = "SecureString"
  value = ""

  tags = local.default_tags

  lifecycle {
    ignore_changes = [value]
  }
}

resource "kubernetes_secret" "terraform-aws-keys" {
  metadata {
    name      = "terraform-aws-keys"
    namespace = "atlantis"
  }

  data = {
    "AWS_ACCESS_KEY_ID"     = aws_ssm_parameter.aws-access-key.value
    "AWS_SECRET_ACCESS_KEY" = aws_ssm_parameter.aws-secret-key.value
  }

  lifecycle {
    ignore_changes = [metadata[0].annotations]
  }
}

resource "aws_ssm_parameter" "nr-account-id" {
  name  = "/global/atlantis/newrelic-account-id"
  type  = "SecureString"
  value = ""

  tags = local.default_tags

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "nr-user-key" {
  name  = "/global/atlantis/newrelic-user-key"
  type  = "SecureString"
  value = ""

  tags = local.default_tags

  lifecycle {
    ignore_changes = [value]
  }
}

resource "kubernetes_secret" "terraform-newrelic-keys" {
  metadata {
    name      = "terraform-newrelic-keys"
    namespace = "atlantis"
  }

  data = {
    "NEW_RELIC_ACCOUNT_ID" = aws_ssm_parameter.nr-account-id.value
    "NEW_RELIC_API_KEY"    = aws_ssm_parameter.nr-user-key.value
  }

  lifecycle {
    ignore_changes = [metadata[0].annotations]
  }
}

resource "aws_ssm_parameter" "pagerduty-token" {
  name  = "/global/atlantis/pagerduty-token"
  type  = "SecureString"
  value = ""

  tags = local.default_tags

  lifecycle {
    ignore_changes = [value]
  }
}

resource "kubernetes_secret" "pagerduty-token" {
  metadata {
    name      = "terraform-pagerduty-token"
    namespace = "atlantis"
  }

  data = {
    "PAGERDUTY_TOKEN" = aws_ssm_parameter.pagerduty-token.value
  }

  lifecycle {
    ignore_changes = [metadata[0].annotations]
  }
}
