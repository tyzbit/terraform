provider "kubernetes" {
  version     = ">= 1.12.0"
  config_path = "~/.kube/config"
}

provider aws {
  region = "us-east-1"

  allowed_account_ids = [
    "785128380673",
  ]
}

locals {

  default_tags = {
    Terraform     = "true"
    Namespace     = "Automation"
    ResourceGroup = "global/atlantis"
  }

  image_tag         = "v0.16.0"
  atlantis_hostname = "atlantis.${local.root_domain}"
  root_domain       = "qtosw.com"

  repo_config = <<EOF
{"repos": [{"id": "/.*/","apply_requirements": ["approved","mergeable"],"allowed_overrides": ["workflow"]}]}
EOF

  env_map = {
    ATLANTIS_DEFAULT_TF_VERSION = "0.13.6"
    ATLANTIS_REPO_CONFIG_JSON   = local.repo_config
    ATLANTIS_ATLANTIS_URL       = "https://${local.atlantis_hostname}"
    ATLANTIS_REPO_WHITELIST     = "github.com/tyzbit/*"
    ATLANTIS_PORT               = 4141
  }
}

terraform {

  required_version = "= 0.13.6"

  backend "s3" {
    bucket         = "tyzbit.terraform"
    key            = "atlantis.tfstate"
    region         = "us-east-1"
    dynamodb_table = "tf-locking-table"
  }
}