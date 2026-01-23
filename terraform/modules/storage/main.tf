#============================================ S3 Bucket ============================================#
# Create S3 Bucket for frontend deployment
resource "aws_s3_bucket" "s3_bucket" {
  bucket        = var.bucket_name
  force_destroy = true

  tags = {
    Name = "${var.project_name}-bucket"
  }
}

# Block public access to the bucket
resource "aws_s3_bucket_public_access_block" "block_public_access" {
  bucket = aws_s3_bucket.s3_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable versioning for backup/recovery
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.s3_bucket.id
  versioning_configuration {
    status = "Disabled"
  }
}

# Enable default encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.s3_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Configure S3 bucket for static website hosting
resource "aws_s3_bucket_website_configuration" "bucket_website_config" {
  bucket = aws_s3_bucket.s3_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

#============================================ CloudFront ============================================#
# Create CloudFront Origin Access Control (OAC)
resource "aws_cloudfront_origin_access_control" "access_control" {
  name                              = "${var.project_name}-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# CloudFront distribution
resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name              = aws_s3_bucket.s3_bucket.bucket_regional_domain_name
    origin_id                = "s3-origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.access_control.id
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  comment             = "${var.project_name} CloudFront Distribution"

  # Custom error responses for SPA (Single Page Applications)
  custom_error_response {
    error_code         = 403
    response_code      = 200
    response_page_path = "/index.html"
  }

  custom_error_response {
    error_code         = 404
    response_code      = 200
    response_page_path = "/index.html"
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "s3-origin"

    # Use managed cache policy (recommended)
    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    # OR use a custom cache policy for more control
    # cache_policy_id = aws_cloudfront_cache_policy.cache_policy.id

    viewer_protocol_policy = "redirect-to-https"
    compress               = true
  }

  # Price class controls which edge locations are used
  price_class = "PriceClass_100" # Use only North America and Europe

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Name = "${var.project_name}-cloudfront-distribution"
  }
}

# S3 bucket policy that allows CloudFront OAC to access the bucket
resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.s3_bucket.id
  policy = data.aws_iam_policy_document.s3_policy.json

  depends_on = [
    aws_cloudfront_distribution.s3_distribution,
    aws_cloudfront_origin_access_control.access_control
  ]
}

# IAM policy document for S3 bucket
data "aws_iam_policy_document" "s3_policy" {
  statement {
    sid    = "AllowCloudFrontOAC"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.s3_bucket.arn}/*"]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.s3_distribution.arn]
    }
  }

  statement {
    sid    = "AllowCloudFrontOACListBucket"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.s3_bucket.arn]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.s3_distribution.arn]
    }
  }
}

#============================================ Redis Elastic Cache Cluster ============================================#
# Create subnet group for ElastiCache
resource "aws_elasticache_subnet_group" "redis_subnet_group" {
  name       = "${var.project_name}-redis-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "${var.project_name}-redis-subnet-group"
  }
}

# Security group for Redis
resource "aws_security_group" "redis_sg" {
  name        = "${var.project_name}-redis-sg"
  description = "Security group for Redis ElastiCache"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Redis access from application servers"
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [var.application_sg_id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-redis-sg"
  }
}

# Create Elasticache Redis Cluster
resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "${var.project_name}-redis"
  engine               = "redis"
  node_type            = var.redis_node_type
  num_cache_nodes      = 1
  parameter_group_name = "default.redis7"
  port                 = 6379
  subnet_group_name    = aws_elasticache_subnet_group.redis_subnet_group.name
  security_group_ids   = [aws_security_group.redis_sg.id]
  apply_immediately    = true

  # Snapshot configuration
  snapshot_retention_limit = 7
  snapshot_window          = "05:00-09:00"
  maintenance_window       = "sun:23:00-mon:01:00"

  tags = {
    Name = "${var.project_name}-redis"
  }
}

#============================================ ALB Logging Bucket ============================================#
# S3 Bucket for ALB access logs
resource "aws_s3_bucket" "alb_logs_bucket" {
  bucket = var.alb_logs_bucket

  tags = {
    Name = "${var.project_name}-alb_logs_bucket"
  }
}

# Block public access to the ALB logs bucket
resource "aws_s3_bucket_public_access_block" "alb_logs_block_public_access" {
  bucket                  = aws_s3_bucket.alb_logs_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Disable versioning for ALB logs bucket
resource "aws_s3_bucket_versioning" "alb_logs_versioning" {
  bucket = aws_s3_bucket.alb_logs_bucket.id
  versioning_configuration {
    status = "Disabled"
  }
}

# Enable default encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "alb_encryption" {
  bucket = aws_s3_bucket.alb_logs_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# S3 bucket policy that allows alb to access the bucket
resource "aws_s3_bucket_policy" "alb_log_bucket_policy" {
  bucket = aws_s3_bucket.alb_logs_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowALBLogDelivery"
        Effect = "Allow"
        Principal = {
          Service = "logdelivery.elasticloadbalancing.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "arn:aws:s3:::muchtodo-alb-logs-bucket/AWSLogs/117139745244/*"
        Action   = "s3:PutObject"
        Resource = "arn:aws:s3:::${aws_s3_bucket.alb_logs_bucket.bucket}/alb-logs/AWSLogs/117139745244/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}
