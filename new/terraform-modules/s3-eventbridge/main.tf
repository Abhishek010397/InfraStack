resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket      = var.s3_bucket
  eventbridge = true
}