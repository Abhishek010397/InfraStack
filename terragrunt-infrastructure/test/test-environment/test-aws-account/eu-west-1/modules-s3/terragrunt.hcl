generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents = <<EOF
provider "aws" {
  profile = "aws-profile"
  region  = "eu-west-1"
}
EOF
}

locals {
  random_id = substr(regex("([a-z0-9]{6}).*", uuid())[0], 0, 6)
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
  s3_buckets   = [
    {
      name                                    = "bucket1-${local.random_id}-test"
      object_expiration_days                  = 2
      object_prefix                           = "/"
      iam_policy_name                         = "bucket1-${local.random_id}-test-policy"
    },
    {
      name                                    = "bucket2-${local.random_id}-test"
      object_expiration_days                  = 2
      object_prefix                           = "/"
      iam_policy_name                         = "bucket2-${local.random_id}-test-policy"
    },
  ]
  tags    = local.tags
}

