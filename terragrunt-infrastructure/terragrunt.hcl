remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
  config = {
    bucket                 = "terragrunt-remote-state"
    key                    = "${path_relative_to_include()}/terraform.tfstate"
    region                 = "us-west-1"
    encrypt                = true
    dynamodb_table         = "terragrunt-dynamodb-lock"
    acl                    = "bucket-owner-full-control"
    skip_bucket_versioning = true
    profile                = "aws-profile"
  }
}
