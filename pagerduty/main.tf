terraform {
  # Require Terraform version 0.13.x (recommended)
  required_version = "~> 0.13.6"
  # Require the latest 2.x version of the New Relic provider
  required_providers {
    pagerduty = {
      source  = "PagerDuty/pagerduty"
      version = "1.8.0"
    }
  }

  backend "s3" {
    bucket         = "tyzbit.terraform"
    key            = "pagerduty.tfstate"
    region         = "us-east-1"
    dynamodb_table = "tf-locking-table"
  }
}

# Configure the PagerDuty provider
provider "pagerduty" {}

provider aws {
  region = "us-east-1"

  allowed_account_ids = [
    "785128380673",
  ]
}
