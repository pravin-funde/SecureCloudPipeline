# --------------------------------------------
# Provider Block: Configure AWS provider
# --------------------------------------------
provider "aws" {
  region = "us-east-1"  # Change this if deploying in a different AWS region
}

# --------------------------------------------
# Create a Secure S3 Bucket
# --------------------------------------------

# checkov:skip=CKV2_AWS_62: Event notifications not needed for dev/demo
# checkov:skip=CKV_AWS_144: Cross-region replication not needed for this project
resource "aws_s3_bucket" "secure_bucket" {
  bucket = "securecloudpipeline-bucket"  # Must be globally unique

  tags = {
    Name        = "securecloudpipeline"
    Environment = "Dev"
  }

  # Allows Terraform to delete the bucket even if it has objects in it (useful for dev/test environments)
  force_destroy = true
}

# ---------------------------------------------------------
# S3 Versioning - Protects against accidental deletions
# ---------------------------------------------------------
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.secure_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

# ---------------------------------------------------------
# KMS Key - For encrypting objects in the bucket
# ---------------------------------------------------------
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
            "kms:ViaService" = "s3.us-east-1.amazonaws.com"
          }
        }
      }
    ]
  })
}


# ---------------------------------------------------------
# Encryption Configuration - Uses AWS KMS
# ---------------------------------------------------------
resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.secure_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3_key.arn
    }
  }
}

# --------------------------------------------
# Apply Strict Public Access Blocking
# --------------------------------------------
resource "aws_s3_bucket_public_access_block" "block_public_access" {
  bucket = aws_s3_bucket.secure_bucket.id

  # Deny all public ACLs
  block_public_acls = true

  # Deny all public bucket policies
  block_public_policy = true

  # Ignore public ACLs set by others
  ignore_public_acls = true

  # Prevent public access even if bucket policy allows it
  restrict_public_buckets = true
}



# ---------------------------------------------------------
# Logging Bucket - Stores access logs from main bucket
# ---------------------------------------------------------

# checkov:skip=CKV2_AWS_62: Event notifications not needed for log bucket in dev
# checkov:skip=CKV_AWS_144: Cross-region replication not required for log bucket in dev
resource "aws_s3_bucket" "log_bucket" {
  bucket = "securecloudpipeline-log-bucket"

  tags = {
    Name        = "securecloudpipeline-log"
    Environment = "Dev"
  }

  force_destroy = true
}
resource "aws_s3_bucket_versioning" "log_bucket_versioning" {
  bucket = aws_s3_bucket.log_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}
#versioning for log bucket
resource "aws_s3_bucket_versioning" "log_bucket_versioning" {
  bucket = aws_s3_bucket.log_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}
#encryption with kms for log_bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "log_bucket_encryption" {
  bucket = aws_s3_bucket.log_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3_key.arn
    }
  }
}
#block all public accessresource "aws_s3_bucket_public_access_block" "log_bucket_block_public_access" {
  bucket = aws_s3_bucket.log_bucket.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}
#lifecycle policy to pass checkov
resource "aws_s3_bucket_lifecycle_configuration" "log_bucket_lifecycle" {
  bucket = aws_s3_bucket.log_bucket.id

  rule {
    id     = "log-retention"
    status = "Enabled"

    expiration {
      days = 90
    }

    noncurrent_version_expiration {
      days = 30
    }
  }
}

# ---------------------------------------------------------
# Logging to log bucket
# ---------------------------------------------------------
resource "aws_s3_bucket_logging" "logging" {
  bucket = aws_s3_bucket.secure_bucket.id

  target_bucket = aws_s3_bucket.log_bucket.id
  target_prefix = "log/"
}