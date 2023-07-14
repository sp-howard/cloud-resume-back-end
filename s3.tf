################# S3 #################

# Website Bucket
resource "aws_s3_bucket" "www_bucket" {
  bucket = var.bucket_name

  lifecycle {
    ignore_changes = [
      website
    ]
  }
}

# Website Configuration
resource "aws_s3_bucket_website_configuration" "www_bucket" {
  bucket = aws_s3_bucket.www_bucket.id

  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "error.html"
  }
}

# Disable "Block Public Access"
resource "aws_s3_bucket_public_access_block" "www_bucket" {
  bucket = aws_s3_bucket.www_bucket.bucket

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Assign Bucket Policy to S3 bucket
resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.www_bucket.id
  policy = data.aws_iam_policy_document.bucket_policy_document.json
}

# Bucket Policy - Allow Public Access
data "aws_iam_policy_document" "bucket_policy_document" {
  statement {
    actions = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.www_bucket.arn}/*"]
    principals {
      type = "*"
      identifiers = ["*"]
  }
}
}

# Redirect Bucket
resource "aws_s3_bucket" "redirect_bucket" {
  bucket = "www.${var.bucket_name}"

  website {
    redirect_all_requests_to = "https://${var.bucket_name}"
  }
}