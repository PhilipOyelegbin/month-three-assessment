output "resource_details" {
  value = {
    alb_log_bucket    = module.storage.output_details.alb_bucket_name
    asg_public_ips    = module.compute.output_details.asg_public_ips
    cloudfront_domain = module.storage.output_details.cf_domain
    cloudfront_id     = module.storage.output_details.cf_id
    load_balancer_dns = module.compute.output_details.alb
    redis_endpoint    = module.storage.output_details.redis_endpoint
    s3_bucket         = module.storage.output_details.bucket_name
  }
  description = "Values of all the resources created."
}