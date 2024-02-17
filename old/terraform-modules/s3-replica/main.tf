locals {
  bucket_mappings = [
    for idx, source_bucket in var.source_bucket_names : {
      source_bucket     = source_bucket
      destination_bucket = try(
        var.override_buckets != null && contains(keys(var.override_buckets), source_bucket) ? var.override_buckets[source_bucket] :
        try(
          length([for dest_bucket in var.destination_bucket_names : dest_bucket if regex(".*-[0-9a-z]+-([a-z0-9]+)$", source_bucket)[0] == regex(".*-[0-9a-z]+-([a-z0-9]+)$", dest_bucket)[0]]) > 0 ?
          [for dest_bucket in var.destination_bucket_names : dest_bucket if regex(".*-[0-9a-z]+-([a-z0-9]+)$", source_bucket)[0] == regex(".*-[0-9a-z]+-([a-z0-9]+)$", dest_bucket)[0]][0] : null
        )
      )
    } if try(
      var.override_buckets != null && contains(keys(var.override_buckets), source_bucket) ? var.override_buckets[source_bucket] :
      try(
        length([for dest_bucket in var.destination_bucket_names : dest_bucket if regex(".*-[0-9a-z]+-([a-z0-9]+)$", source_bucket)[0] == regex(".*-[0-9a-z]+-([a-z0-9]+)$", dest_bucket)[0]]) > 0 ?
        [for dest_bucket in var.destination_bucket_names : dest_bucket if regex(".*-[0-9a-z]+-([a-z0-9]+)$", source_bucket)[0] == regex(".*-[0-9a-z]+-([a-z0-9]+)$", dest_bucket)[0]][0] : null
      )
    ) != null
  ]
}

data "aws_caller_identity" "current" {}

resource "aws_iam_role" "replication" {
  for_each           = { for idx, val in local.bucket_mappings : idx => val if val.destination_bucket != null }
  name               = "${each.value.source_bucket}-replication-role"
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
  for_each    = { for idx, val in local.bucket_mappings : idx => val if val.destination_bucket != null }
  name        = "${each.value.source_bucket}-replication-policy"
  description = "IAM policy for S3 bucket ${each.value.source_bucket}"
  tags        = var.tags
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "s3:GetReplicationConfiguration",
          "s3:ListBucket"
        ],
        "Effect" : "Allow",
        "Resource" : [
          "arn:aws:s3:::${each.value.source_bucket}"
        ]
      },
      {
        "Action" : [
          "s3:GetObjectVersion",
          "s3:GetObjectVersionAcl"
        ],
        "Effect" : "Allow",
        "Resource" : [
          "arn:aws:s3:::${each.value.source_bucket}/*"
        ]
      },
      {
        "Action" : [
          "s3:ReplicateObject",
          "s3:ReplicateDelete"
        ],
        "Effect" : "Allow",
        "Resource" : "arn:aws:s3:::${each.value.destination_bucket}/*"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "replication" {
  for_each   = { for idx, val in local.bucket_mappings : idx => val if val.destination_bucket != null }
  name       = "${each.value.source_bucket}-replication-role-attachment"
  roles      = [aws_iam_role.replication[each.key].name]
  policy_arn = aws_iam_policy.replication_policy[each.key].arn
}

resource "aws_s3_bucket_replication_configuration" "replication" {
  for_each  = { for idx, val in local.bucket_mappings : idx => val if val.destination_bucket != null }
  role      = aws_iam_role.replication[each.key].arn
  bucket    = each.value.source_bucket
  rule {
    id                        = "something-with-kms-and-filter"
    status                    = "Enabled"
    priority                  = 10
    delete_marker_replication {
      status =  "Disabled"
    }
    source_selection_criteria {
      replica_modifications {
        status = "Enabled"
      }
      sse_kms_encrypted_objects {
        status = "Enabled"
      }
    }
    filter {
      prefix = "one"
      tag {
        key   = "ReplicateMe"
        value = "Yes"
      }
    }
    destination {
      bucket        = "arn:aws:s3:::${each.value.destination_bucket}"
      storage_class = "STANDARD"

      encryption_configuration {
        replica_kms_key_id = var.kms_key_arn
      }
      account            = data.aws_caller_identity.current.account_id

      access_control_translation {
        owner = "Destination"
      }
      replication_time {
        status  = "Enabled"
        time {
          minutes = 15
        }
      }
      metrics {
        status  = "Enabled"
        event_threshold {
          minutes = 15
        }
      }
    }
  }
}
