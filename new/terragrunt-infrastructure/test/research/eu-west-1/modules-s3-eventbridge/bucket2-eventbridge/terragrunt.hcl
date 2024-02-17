include "root" {
  path = find_in_parent_folders()
}

include "providers" {
  path = find_in_parent_folders("providers.hcl")
}

dependency "eu_west_1_s3" {
  config_path = "../../modules-s3/bucket2"
}

terraform {
  source = "source//s3-eventbridge?ref=v1.0"
}

inputs = {
  s3_bucket = dependency.eu_west_1_s3.outputs.s3_bucket_name
}