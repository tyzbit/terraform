terraform {
  # Require Terraform version 0.13.x (recommended)
  required_version = "~> 0.13.6"
  # Require the latest 2.x version of the New Relic provider
  required_providers {
    newrelic = {
      source  = "newrelic/newrelic"
      version = "~> 2.18.0"
    }
  }

  backend "s3" {
    bucket         = "tyzbit.terraform"
    key            = "newrelic.tfstate"
    region         = "us-east-1"
    dynamodb_table = "tf-locking-table"
  }
}

provider "newrelic" {
  version = "~> 2.18.0"
  region  = "US"
}

provider aws {
  region = "us-east-1"

  allowed_account_ids = [
    "785128380673",
  ]
}
