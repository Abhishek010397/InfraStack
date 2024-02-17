include "root" {
  path = find_in_parent_folders()
}

include "providers" {
  path = find_in_parent_folders("providers.hcl")
}

dependency "us_east_1_s3" {
  config_path = "../../modules-s3/bucket3"
}

terraform {
  source = "source//s3-eventbridge?ref=v1.0"
}

inputs = {
  s3_bucket = dependency.us_east_1_s3.outputs.s3_bucket_name
}