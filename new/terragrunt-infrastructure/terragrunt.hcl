remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
  config = {
    bucket                 = "terragrunt-backend"
    key                    = "${path_relative_to_include()}/terraform.tfstate"
    region                 = "eu-west-1"
    encrypt                = true
    dynamodb_table         = "terragrunt-state-dynamodb-lock"
    acl                    = "bucket-owner-full-control"
    skip_bucket_versioning = false
    profile                = "aws-profile"
  }
}
