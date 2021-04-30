terraform {
  # Require Terraform version 0.13.x (recommended)
  required_version = "~> 0.13.6"
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.8.0"
    }
  }

  backend "s3" {
    bucket         = "tyzbit.terraform"
    key            = "digitalocean.tfstate"
    region         = "us-east-1"
    dynamodb_table = "tf-locking-table"
  }
}

provider "digitalocean" {
  version = "~> 2.8.0"
}

provider aws {
  region = "us-east-1"

  allowed_account_ids = [
    "785128380673",
  ]
}
