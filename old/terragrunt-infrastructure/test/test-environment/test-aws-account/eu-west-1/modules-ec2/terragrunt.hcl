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
  default_tags = {
    Environment    = "Test"
    Customer_Name  = "Test"
  }
  override_tags = {
    CreatedBy = "Terragrunt"
  }
  tags = merge(local.default_tags, local.override_tags)
}

include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "source"
}

dependency "modules-s3" {
  config_path = "../modules-s3"
}

inputs = {
  instance_role_name         = "instance-role"
  instance_profile_role_name = "instance-profile-role"
  instance_policy_arn        = [for policy_arn in dependency.modules-s3.outputs.iam_policy_arns : policy_arn]
  tags                       = local.tags
}