module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"
  version = "v3.15.1"
  bucket = var.name
  acl    = "private"

  control_object_ownership = true
  object_ownership         = "BucketOwnerPreferred"

  versioning = {
    enabled = true
  }

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  lifecycle_rule = var.object_expiration_days != null ? [
    {
      id      = "object-expiration"
      status  = "Enabled"
      prefix  = var.bucket_object_prefix
      enabled = true

      expiration = {
        days = var.object_expiration_days
      }
    }
  ] : []

  metric_configuration = [
    {
      name = "all"
    }
  ]

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        kms_master_key_id = var.kms_arn
        sse_algorithm     = "aws:kms"
      }
      bucket_key_enabled  = var.bucket_key
    }
  }
  tags = var.tags
}

resource "aws_iam_policy" "bucket_access" {
  name        = var.iam_policy_name
  description = "IAM policy for S3 bucket ${var.name}"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:PutObjectVersionTagging",
          "s3:PutObjectTagging",
          "s3:GetObjectVersionTagging",
          "s3:GetObjectTagging",
          "s3:DeleteObject"
        ],
        Effect   = "Allow",
        Resource = "arn:aws:s3:::${var.name}/*",
      },
      {
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ],
        Effect   = "Allow",
        Resource = "arn:aws:s3:::${var.name}",
      }
    ],
  })
}
