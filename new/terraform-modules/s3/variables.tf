variable "name" {
  type        = string
  description = "Name of the S3 bucket to be created."
  validation {
    condition     = can(regex("([a-z0-9]+-){2}[a-z0-9]{6}(-[a-z0-9]+)+", var.name))
    error_message = "Bucket names need to comply with the AWS naming conventions"
  }
}

variable "object_expiration_days" {
  type        = number
  description = "Expiration period in days that should be applied to objects in the bucket."
  default     = null
}

variable "iam_policy_name" {
  type        = string
  description = "Name of the IAM policy to be created. The policy will grant write access to the bucket."
}

variable "kms_arn" {
  type        = string
  description = "ARN of the kms key that should be used for server-side encryption of S3 objects."
}

variable "bucket_object_prefix" {
  type = string
  description = "Bucket Object Prefix required for Lifecycle policy"
  default = ""
}

variable "bucket_key" {
  type        = bool
  description = "Key for encrypting and decrypting Bucket Objects"
  default     = false
}


variable "tags" {
  type        = map(string)
  description = "Tags for S3 buckets"
}