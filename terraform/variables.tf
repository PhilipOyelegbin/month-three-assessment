variable "project_name" {
  description = "The project name"
  type        = string
}

variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
}

variable "instance_type" {
  description = "AWS instance type for EC2"
  type        = string
}