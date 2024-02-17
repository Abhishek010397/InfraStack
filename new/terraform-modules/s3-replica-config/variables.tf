variable "tags" {
  type = map(string)
  description = "Tags for s3 buckets"
}

variable "source_bucket_name" {
  type = string
  description = "created source s3 bucket name"
}

variable "destination_bucket_name" {
  type = string
  description = "created destination s3 bucket name"
}

variable "replication_filter_prefix" {
  type = string
  description = "The filter prefix for replication"
}