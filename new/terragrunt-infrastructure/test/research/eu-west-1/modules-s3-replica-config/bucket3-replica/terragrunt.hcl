locals {
  common = read_terragrunt_config(find_in_parent_folders("common.hcl"))
  tags   = local.common.locals.tags
}

include "root" {
  path = find_in_parent_folders()
}

include "providers" {
  path = find_in_parent_folders("providers.hcl")
}

dependency "eu_west_1_s3" {
  config_path = "../../modules-s3/bucket3"
}

dependency "us_east_1_s3" {
  config_path = "../../../us-east-1/modules-s3/bucket3"
}

terraform {
  source = "source//s3-replica-config?ref=v1.0"
}

inputs = {
  source_bucket_name        = dependency.eu_west_1_s3.outputs.s3_bucket_name
  destination_bucket_name   = dependency.us_east_1_s3.outputs.s3_bucket_name
  replication_filter_prefix = "/copy/eff"
  tags                      = local.tags
}