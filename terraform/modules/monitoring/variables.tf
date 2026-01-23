variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "region" {
  description = "AWS Region"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "vpc_cidr_blocks" {
  description = "VPC CIDR blocks for internal communication"
  type        = list(string)
}

variable "log_retention_days" {
  description = "Number of days to retain logs in CloudWatch"
  type        = number
  default     = 30
}

variable "alb_log_retention_days" {
  description = "Number of days to retain ALB access logs"
  type        = number
  default     = 90
}

variable "enable_alb_access_logs" {
  description = "Enable ALB access logs"
  type        = bool
  default     = true
}

variable "application_sg_ids" {
  description = "List of application security group IDs"
  type        = list(string)
}
