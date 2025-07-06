# --------------------------------------------
# Provider Block: Configure AWS provider
# --------------------------------------------
provider "aws" {
  region = "ap-south-1"  # Change this if deploying in a different AWS region
}

# --------------------------------------------
# Create a Secure S3 Bucket (Main App Bucket)
# --------------------------------------------

# Skip Checkov rules for secure bucket
#checkov:skip=CKV2_AWS_62: Event notifications not needed for dev/demo
#checkov:skip=CKV_AWS_144: Cross-region replication not required for dev
resource "aws_s3_bucket" "secure_bucket" {
  bucket = "securecloudpipeline-bucket" # Must be globally unique

  tags = {
    Name        = "securecloudpipeline"
    Environment = "Dev"
  }

  force_destroy = true  # Allows deletion even with objects (for dev/test use)
}

# Enable versioning to protect against accidental deletion
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.secure_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Create KMS Key for encryption
resource "aws_kms_key" "s3_key" {
  description             = "KMS key for S3 encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17",
    Id      = "s3-kms-key",
    Statement = [
      {
        Sid       = "Enable IAM User Permissions",
        Effect    = "Allow",
        Principal = {
          AWS = "*"
        },
        Action    = "kms:*",
        Resource  = "*",
        Condition = {
          StringEquals = {
            "kms:ViaService" = "s3.ap-south-1.amazonaws.com"
          }
        }
      }
    ]
  })
}

# Enable server-side encryption on bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.secure_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3_key.arn
    }
  }
}

# Block all public access to secure bucket
resource "aws_s3_bucket_public_access_block" "block_public_access" {
  bucket = aws_s3_bucket.secure_bucket.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "secure_bucket_lifecycle" {
  bucket = aws_s3_bucket.secure_bucket.id

  rule {
    id     = "basic-lifecycle"
    status = "Enabled"

    expiration {
      days = 90
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}


# --------------------------------------------
# Logging Bucket (Receives Logs from App Bucket)
# --------------------------------------------


# Skip Checkov for log bucket
#checkov:skip=CKV2_AWS_62: Event notifications not needed for dev/demo
#checkov:skip=CKV_AWS_144: Cross-region replication not needed for demo
resource "aws_s3_bucket" "log_bucket" {
  bucket = "securecloudpipeline-log-bucket"

  tags = {
    Name        = "securecloudpipeline-log"
    Environment = "Dev"
  }

  force_destroy = true
}

# Versioning for log bucket
resource "aws_s3_bucket_versioning" "log_bucket_versioning" {
  bucket = aws_s3_bucket.log_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Encryption for log bucket with same KMS key
resource "aws_s3_bucket_server_side_encryption_configuration" "log_bucket_encryption" {
  bucket = aws_s3_bucket.log_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3_key.arn
    }
  }
}

# Block public access for log bucket (was malformed earlier ❌)
resource "aws_s3_bucket_public_access_block" "log_bucket_block_public_access" {
  bucket = aws_s3_bucket.log_bucket.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

# Lifecycle policy to expire old logs
resource "aws_s3_bucket_lifecycle_configuration" "log_bucket_lifecycle" {
  bucket = aws_s3_bucket.log_bucket.id

  rule {
    id     = "log-retention"
    status = "Enabled"

    expiration {
      days = 90
    }

    noncurrent_version_expiration {
      noncurrent_days = 30
    }

     # Abort incomplete multipart uploads after 7 days
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

# Enable logging from secure_bucket to log_bucket
resource "aws_s3_bucket_logging" "logging" {
  bucket = aws_s3_bucket.secure_bucket.id

  target_bucket = aws_s3_bucket.log_bucket.id
  target_prefix = "log/"
}
