resource "aws_s3_bucket" "data_lake" {
  bucket = "${var.lake_bucket_name}-${var.environment}"

  force_destroy = true
}

# Enable versioning
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.data_lake.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Enabling Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "s3_encryption" {
  bucket = aws_s3_bucket.data_lake.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# creating folders (keys, objects with trailing slashes)
resource "aws_s3_bucket_object" "zones" {
  for_each = toset(["raw/", "processed/", "analytics/"])

  bucket = aws_s3_bucket.data_lake.id
  key = each.value
}

# adding lifecycle rules
resource "aws_s3_bucket_lifecycle_configuration" "lake_lifecycle" {
  bucket = aws_s3_bucket.data_lake.id

  rule {
    id = "move-to-glacier"
    status = "Enabled"

    transition {
      days = 30
      storage_class = "GLACIER"
    }

    expiration {
      days = 365
    }
  }
}
