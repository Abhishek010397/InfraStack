locals {
  common       = read_terragrunt_config(find_in_parent_folders("common.hcl"))
  tags         = local.common.locals.tags
  name         = local.common.locals.name
  environment  = local.common.locals.environment
}

include "root" {
  path = find_in_parent_folders()
}

include "providers" {
  path = find_in_parent_folders("providers.hcl")
}

terraform {
  source = "source//s3?ref=v1.0"
}

dependency "random_id" {
  config_path = "../../random-id"
}

inputs = {
  name                   = "${local.name}-${local.environment}-${dependency.random_id.outputs.random_id}-bucket2"
  object_expiration_days = 2
  bucket_object_prefix   = "/"
  iam_policy_name        = "${local.name}-${local.environment}-${dependency.random_id.outputs.random_id}-bucket2-role"
  kms_arn                = null
  bucket_key             = true
  tags                   = local.tags
}