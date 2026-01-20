output "resource_details" {
  value = {
    vpc_id            = module.network.output_details.id
    cidr_block        = module.network.output_details.cidr_block
    public_subnet_id  = module.network.output_details.public_subnet_id
    private_subnet_id = module.network.output_details.private_subnet_id
    lt_id             = module.compute.output_details.lt_id
    asg_id            = module.compute.output_details.asg_id
    asg_public_ips    = module.compute.output_details.asg_public_ips
    load_balancer_dns = module.compute.output_details.alb
    s3_bucket       = module.storage.output_details.bucket_name
    cloudfront_domain = module.storage.output_details.cf_domain
    redis_endpoint    = module.storage.output_details.redis_endpoint
  }
  description = "Values of all the resources created."
}