output "kms_key_arn" {
  description = "The ARN of the created KMS key"
  value = aws_kms_key.kms_key.arn
}
