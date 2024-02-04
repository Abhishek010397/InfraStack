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
    Environment   = "Test"
    Customer_Name = "Test"
  }
  override_tags = {
    CreatedBy = "Terragrunt"
  }
  tags = merge(local.default_tags, local.override_tags)
}

include "root" {
  path = find_in_parent_folders()
}

dependency "us-east-1-s3" {
  config_path = "../modules-s3"
}

dependency "eu-west-1-s3" {
  config_path = "../../eu-west-1/modules-s3"
}

dependency "eu-west-1-kms" {
  config_path = "../../eu-west-1/modules-kms"
}

terraform {
  source  = "source"
}

inputs = {
  source_bucket_names        =  [ for s3_bucket_name in dependency.us-east-1-s3.outputs.bucket_names : s3_bucket_name ]
  destination_bucket_names   =  [ for s3_bucket_name in dependency.eu-west-1-s3.outputs.bucket_names : s3_bucket_name ]
  kms_key_arn                =  dependency.eu-west-1-kms.outputs.kms_key_arn
  override_buckets           =  {
    "bucket1-5555cd-test"    = "bucket3-e18587-test",
    "bucket2-5555cd-test"    = "bucket4-e18587-test"
  }
  tags                       =  local.tags
}