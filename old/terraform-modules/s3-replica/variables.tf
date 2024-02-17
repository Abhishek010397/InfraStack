variable "tags" {
  type = map(string)
  description = "Tags for creation of S3 buckets"
}

variable "source_bucket_names" {
  type = list(string)
  description = "List of created source s3 bucket names"
}

variable "destination_bucket_names" {
  type = list(string)
  description = "List of created destination s3 bucket names"
}

variable "override_buckets" {
  type = map(string)
  default = {}
  description = "Map of objects for overriding replica buckets"
}

variable "kms_key_arn" {
  type = string
  description = "The ARN for the created KMS key"
}