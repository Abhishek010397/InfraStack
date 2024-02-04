module "s3_bucket" {
  for_each = { for idx, val in var.s3_buckets : idx => val }

  source   = "terraform-aws-modules/s3-bucket/aws"
  version  = "v3.15.1"
  bucket   = each.value.name
  acl      = "private"

  control_object_ownership = true
  object_ownership         = "BucketOwnerPreferred"

  versioning = {
    enabled = true
  }

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  lifecycle_rule = each.value.object_expiration_days != null ? [
    {
      id      = "object-expiration"
      status  = "Enabled"
      prefix  = each.value.object_prefix
      enabled = true

      expiration = {
        days = each.value.object_expiration_days
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
      bucket_key_enabled  = true
    }
  }
  tags = var.tags
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  count       = length(module.s3_bucket) > 0 ? 1 : 0
  bucket      = module.s3_bucket[count.index].s3_bucket_id
  eventbridge = true
}

resource "aws_iam_policy" "bucket_access" {
  for_each    = { for idx, val in var.s3_buckets : idx => val }
  name        = each.value.iam_policy_name
  description = "IAM policy for S3 bucket ${each.value.name}"
  tags        = var.tags
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
        Resource = "arn:aws:s3:::${each.value.name}/*",
      },
      {
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ],
        Effect   = "Allow",
        Resource = "arn:aws:s3:::${each.value.name}",
      }
    ],
  })
  depends_on = [module.s3_bucket]
}