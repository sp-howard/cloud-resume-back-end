################# S3 #################

########### Website bucket ###########
resource "aws_s3_bucket" "www_bucket" {
  bucket = var.bucket_name

  lifecycle {
    ignore_changes = [
      website
    ]
  }
}

resource "aws_s3_bucket_website_configuration" "www_bucket" {
  bucket = aws_s3_bucket.www_bucket.id

  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_public_access_block" "www_bucket" {
  bucket = aws_s3_bucket.www_bucket.bucket

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Assign bucket policy to let the CloudFront OAI get objects
resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.www_bucket.id
  policy = data.aws_iam_policy_document.bucket_policy_document.json
}

# Define bucket policy
data "aws_iam_policy_document" "bucket_policy_document" {
  statement {
    actions = ["s3:GetObject"]
    resources = [
      aws_s3_bucket.www_bucket.arn,
      "${aws_s3_bucket.www_bucket.arn}/*"
    ]
    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.oai.iam_arn]
    }
  }
}