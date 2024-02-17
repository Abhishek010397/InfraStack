data "aws_caller_identity" "current" {}

resource "aws_iam_role" "replication" {
  name               = "${var.source_bucket_name}-replication-role"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
  tags       = var.tags
}

resource "aws_iam_policy" "replication_policy" {
  name        = "${var.source_bucket_name}-replication-policy"
  description = "IAM policy for S3 bucket ${var.source_bucket_name}"
  tags        = var.tags
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "s3:ListBucket",
          "s3:GetReplicationConfiguration",
          "s3:GetObjectVersionForReplication",
          "s3:GetObjectVersionAcl",
          "s3:GetObjectVersionTagging",
          "s3:GetObjectRetention",
          "s3:GetObjectLegalHold"
        ],
        "Effect" : "Allow",
        "Resource" : [
          "arn:aws:s3:::${var.source_bucket_name}"
        ]
      },
      {
        "Action" : [
          "s3:GetObjectVersionForReplication",
          "s3:GetObjectVersionAcl",
          "s3:GetObjectVersionTagging"
        ],
        "Effect" : "Allow",
        "Resource" : [
          "arn:aws:s3:::${var.source_bucket_name}/*"
        ]
      },
      {
        "Action" : [
          "s3:ReplicateObject",
          "s3:ReplicateDelete",
          "s3:ReplicateTags",
          "s3:ObjectOwnerOverrideToBucketOwner"
        ],
        "Effect" : "Allow",
        "Resource" : "arn:aws:s3:::${var.destination_bucket_name}/*"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "replication" {
  name       = "${var.source_bucket_name}-replication-role-attachment"
  roles      = [aws_iam_role.replication.name]
  policy_arn = aws_iam_policy.replication_policy.arn
}

resource "aws_s3_bucket_replication_configuration" "replication" {
  role      = aws_iam_role.replication.arn
  bucket    = var.source_bucket_name
  rule {
    status = "Enabled"
    delete_marker_replication {
      status =  "Disabled"
    }
    filter {
      prefix = var.replication_filter_prefix
    }
    destination {
      bucket             = "arn:aws:s3:::${var.destination_bucket_name}"
      account            = data.aws_caller_identity.current.account_id
      access_control_translation {
        owner = "Destination"
      }
    }
  }
}
