output "iam_policy_arn" {
  description = "The name of the created IAM policy"
  value       = aws_iam_policy.bucket_access.arn
}

output "s3_arn" {
  value = module.s3_bucket.s3_bucket_arn
}

output "s3_bucket_name" {
  value = module.s3_bucket.s3_bucket_id
}