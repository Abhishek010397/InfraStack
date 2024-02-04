output "iam_policy_arns" {
  description = "The names of the created IAM policies"
  value       = [for policy in aws_iam_policy.bucket_access : policy.arn]
}

output "bucket_names" {
  description = "The name of the created buckets"
  value       = [for s3_bucket in module.s3_bucket : s3_bucket.s3_bucket_id]
}

output "bucket_arns" {
  description = "The bucket arns created by the module"
  value       = [for s3_bucket in module.s3_bucket: s3_bucket.s3_bucket_arn]
}

output "bucket_region" {
  description = "The created bucket regions"
  value       = [for s3_bucket in module.s3_bucket: s3_bucket.s3_bucket_region]
}