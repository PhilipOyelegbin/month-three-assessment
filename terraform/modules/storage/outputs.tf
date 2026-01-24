output "output_details" {
  description = "Details of storage resources created."
  value = {
    bucket_name     = aws_s3_bucket.s3_bucket.bucket
    alb_bucket_name = aws_s3_bucket.alb_logs_bucket.bucket
    s3_endpoint     = aws_s3_bucket_website_configuration.bucket_website_config.website_endpoint
    cf_zone_id      = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
    cf_domain       = aws_cloudfront_distribution.s3_distribution.domain_name
    cf_id           = aws_cloudfront_distribution.s3_distribution.id
    redis_endpoint  = aws_elasticache_cluster.redis.cache_nodes[0].address
  }
}

