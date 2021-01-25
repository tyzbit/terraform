resource "pagerduty_team" "qtosw-administrators" {
  name        = "QTOSW Administrators"
  description = "Quick, Administrate Something Witty"
}

resource "pagerduty_team_membership" "tyzbit-qtosw" {
  user_id = pagerduty_user.tyzbit.id
  team_id = pagerduty_team.qtosw-administrators.id
  role    = "manager"
}

resource "aws_ssm_parameter" "tyzbit-email" {
  name  = "/global/pagerduty/tyzbit-email"
  type  = "SecureString"
  value = ""

  lifecycle {
    ignore_changes = [value]
  }
}

resource "pagerduty_user" "tyzbit" {
  name      = "Tyzbit"
  email     = aws_ssm_parameter.tyzbit-email.value
  role      = "owner"
  time_zone = "America/New_York"
}

resource "pagerduty_user_contact_method" "tyzbit-email" {
  user_id = pagerduty_user.tyzbit.id
  type    = "email_contact_method"
  address = aws_ssm_parameter.tyzbit-email.value
  label   = "Email"
}

resource "aws_ssm_parameter" "tyzbit-phone-address" {
  name  = "/global/pagerduty/tyzbit-phone-address"
  type  = "SecureString"
  value = ""

  lifecycle {
    ignore_changes = [value]
  }
}

# resource "pagerduty_user_contact_method" "tyzbit-push" {
#   user_id = pagerduty_user.tyzbit.id
#   type    = "push_notification_contact_method"
#   address = aws_ssm_parameter.tyzbit-phone-address.value
#   label   = "Push"
# }

# resource "pagerduty_user_notification_rule" "tyzbit-push-high" {
#   user_id                = pagerduty_user.tyzbit.id
#   start_delay_in_minutes = 0
#   urgency                = "high"

#   contact_method = {
#     type = "push_notification_contact_method"
#     id   = pagerduty_user_contact_method.tyzbit-push.id
#   }
# }

resource "aws_ssm_parameter" "tyzbit-phone" {
  name  = "/global/pagerduty/tyzbit-phone"
  type  = "SecureString"
  value = ""

  lifecycle {
    ignore_changes = [value]
  }
}

resource "pagerduty_user_contact_method" "tyzbit-sms" {
  user_id      = pagerduty_user.tyzbit.id
  type         = "sms_contact_method"
  country_code = 1
  address      = aws_ssm_parameter.tyzbit-phone.value
  label        = "SMS"
}

resource "pagerduty_user_notification_rule" "tyzbit-sms-high" {
  user_id                = pagerduty_user.tyzbit.id
  start_delay_in_minutes = 5
  urgency                = "high"

  contact_method = {
    type = "sms_contact_method"
    id   = pagerduty_user_contact_method.tyzbit-sms.id
  }
}

resource "pagerduty_user_contact_method" "tyzbit-phone" {
  user_id      = pagerduty_user.tyzbit.id
  type         = "phone_contact_method"
  country_code = 1
  address      = aws_ssm_parameter.tyzbit-phone.value
  label        = "Phone"
}

resource "pagerduty_user_notification_rule" "tyzbit-phone-high" {
  user_id                = pagerduty_user.tyzbit.id
  start_delay_in_minutes = 15
  urgency                = "high"

  contact_method = {
    type = "phone_contact_method"
    id   = pagerduty_user_contact_method.tyzbit-phone.id
  }
}
