variable "s3_buckets" {
  type = list(object({
    name                      = string
    object_expiration_days    = optional(number)
    object_prefix             = string
    iam_policy_name           = string
  }))
  description = "List of s3 buckets that will be created"

  validation {
    condition = alltrue([
      for o in var.s3_buckets : can(regex("([a-z0-9]+-){2}[a-z0-9]{6}(-[a-z0-9]+)+", o.name))])
    error_message = "Bucket names need to comply with the validation"
  }
}

variable "kms_arn" {
  type        = string
  description = "ARN of the kms key used for server-side encryption of S3 objects."
}

variable "tags" {
  type = map(string)
  description = "Tags for creation of S3 buckets"
}

