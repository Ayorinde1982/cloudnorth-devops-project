# Create S3 Bucket for static content
resource "aws_s3_bucket" "static_content" {
  bucket = var.bucket_name

  tags = {
    Name        = var.bucket_name
    Environment = var.environment
    Project     = var.project_name
  }
}

# Configure S3 Bucket Ownership Controls
resource "aws_s3_bucket_ownership_controls" "static_content" {
  bucket = aws_s3_bucket.static_content.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# Configure S3 Bucket Public Access Block
resource "aws_s3_bucket_public_access_block" "static_content" {
  bucket = aws_s3_bucket.static_content.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Configure S3 Bucket ACL
resource "aws_s3_bucket_acl" "static_content" {
  depends_on = [
    aws_s3_bucket_ownership_controls.static_content,
    aws_s3_bucket_public_access_block.static_content,
  ]

  bucket = aws_s3_bucket.static_content.id
  acl    = "public-read"
}

# Configure S3 Bucket Website
resource "aws_s3_bucket_website_configuration" "static_content" {
  bucket = aws_s3_bucket.static_content.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

output "bucket_id" {
  value = aws_s3_bucket.static_content.id
}

output "bucket_website_endpoint" {
  value = aws_s3_bucket.static_content.website_endpoint
}
