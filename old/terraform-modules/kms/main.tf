resource "aws_kms_key" "kms_key" {
  description             = "S3 bucket replication KMS key"
  deletion_window_in_days = 7
  tags                    = var.tags
}