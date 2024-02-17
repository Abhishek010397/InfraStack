generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents = <<EOF
provider "aws" {
  profile = "aws-profile"
  region  = "us-east-1"
}
EOF
}

locals {
  default_tags = {
    Environment    = "Test"
    Customer_Name  = "Test"
  }
  override_tags = {
    CreatedBy = "Terragrunt"
  }
  tags       = merge(local.default_tags, local.override_tags)
}

include "root" {
  path = find_in_parent_folders()
}

terraform {
  source  = "source"
}

inputs = {
  tags = local.tags
}
