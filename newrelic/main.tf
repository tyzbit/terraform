terraform {
  # Require Terraform version 0.13.x (recommended)
  required_version = "~> 0.13.6"
  # Require the latest 2.x version of the New Relic provider
  required_providers {
    newrelic = {
      source  = "newrelic/newrelic"
      version = "~> 2.15.0"
    }
  }

  backend "s3" {
    bucket         = "tyzbit.terraform"
    key            = "synthetics.tfstate"
    region         = "us-east-1"
    dynamodb_table = "tf-locking-table"
  }
}

provider "newrelic" {
  version    = "~> 2.15.0"
  account_id = var.nr_account_id
  api_key    = var.nr_user_api_key
  region     = "US"
}

provider aws {
  region = "us-east-1"

  allowed_account_ids = [
    "785128380673",
  ]
}