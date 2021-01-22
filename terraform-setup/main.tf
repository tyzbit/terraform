locals {
  account_id       = "785128380673"
  account_name     = "tyzbit"
  terraform_bucket = "tyzbit.terraform"
  aws_region       = "us-east-1"
}

locals {
  default_tags = {
    Terraform = "True"
  }
}

provider aws {
  region = "us-east-1"

  allowed_account_ids = [
    "785128380673",
  ]
}

terraform {

  required_version = "= 0.13.6"

  backend "s3" {
    bucket         = "tyzbit.terraform"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "tf-locking-table"
  }
}
