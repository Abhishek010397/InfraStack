generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "aws" {
  profile = "aws-profile"
  region  = "eu-west-1"
}
EOF
}