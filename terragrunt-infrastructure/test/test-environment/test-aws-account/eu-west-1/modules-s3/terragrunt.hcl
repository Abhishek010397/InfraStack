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
  s3_bucket_config = read_terragrunt_config(find_in_parent_folders("s3_buckets.hcl"))
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

inputs = merge(
  {
    s3_buckets   = [
      for bucket in local.s3_bucket_config.inputs.s3_buckets:
      {
        name                   = "aws-account-${local.random_id}-${bucket.name}"
        object_expiration_days = bucket.object_expiration_days
        object_prefix          = bucket.object_prefix
      }
  ]
  tags    = local.tags
  }
)

