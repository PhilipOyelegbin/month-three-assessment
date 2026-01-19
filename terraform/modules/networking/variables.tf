variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.8.0.0/16"
}

variable "pub_cidr_block" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.8.1.0/24", "10.8.2.0/24"]
}

variable "priv_cidr_block" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.8.3.0/24", "10.8.4.0/24"]
}

variable "db_cidr_block" {
  description = "List of CIDR blocks for database subnets"
  type        = list(string)
  default     = ["10.8.5.0/24", "10.8.6.0/24"]
}

variable "enable_nat_high_availability" {
  description = "Enable NAT Gateway high availability, one per AZ"
  type        = bool
  default     = false
}

variable "create_database_subnets" {
  description = "Create dedicated database subnets"
  type        = bool
  default     = false
}
