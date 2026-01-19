variable "project_name" {
  description = "The project name for tagging resources"
  type        = string
}

variable "ami_id" {
  description = "The ID of the AMI to use for the EC2 instance"
  type        = string
}

variable "ec2_instance_type" {
  description = "The instance type for the EC2 instance"
  type        = string
}

variable "public_subnet_id" {
  description = "The public subnet ID"
  type        = list(string)
}

variable "private_subnet_id" {
  description = "The private subnet ID"
  type        = list(string)
}

variable "vpc_id" {
  description = "The VPC ID"
  type        = string
}

variable "vpc_cidr_blocks" {
  description = "List of VPC cidr blocks"
  type        = list(string)
}

variable "region" {
  description = "The deployment region"
  type        = string
}

variable "enable_alb_access_logs" {
  description = "Enable ALB access logs"
  type        = bool
  default     = false
}

# variable "alb_logs_s3_bucket" {
#   description = "S3 bucket for ALB access logs"
#   type        = string
# }

variable "enable_s3_access" {
  description = "Enable S3 access for EC2 instances"
  type        = bool
  default     = false
}

variable "s3_bucket_name" {
  description = "S3 bucket name for application access"
  type        = string
}

variable "enable_ssm_access" {
  description = "Enable SSM Session Manager access"
  type        = bool
  default     = true
}

# variable "application_logs_name" {
#   description = "The cloudwatch application log name"
#   type = string
# }

# variable "application_ports" {
#   description = "Additional application ports to open"
#   type        = list(number)
#   default     = []
# }