# --------------------------------------------
# Provider Block: Configure AWS provider
# --------------------------------------------
provider "aws" {
  region = "us-east-1"  # Change this if deploying in a different AWS region
}

# --------------------------------------------
# Create a Secure S3 Bucket
# --------------------------------------------
resource "aws_s3_bucket" "secure_bucket" {
  bucket = "securecloudpipeline-bucket"  # Must be globally unique

  tags = {
    Name        = "securecloudpipeline"
    Environment = "Dev"
  }

  # Allows Terraform to delete the bucket even if it has objects in it (useful for dev/test environments)
  force_destroy = true
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
