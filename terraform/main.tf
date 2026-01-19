#============================================ Define Provider ============================================#
terraform {
  required_version = ">= 1.14.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.27.0"
    }
  }

  backend "s3" {
    bucket  = "muchtodo-remote-state"
    key     = "muchtodo-terraform.tfstate"
    region  = "eu-west-2"
    encrypt = true
  }
}

provider "aws" {
  region = var.aws_region
}

#============================================ Deployment Infrastructure ============================================#
# Define the ami data
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

# Provision vpc infrastructure via Network module
module "network" {
  source       = "./modules/networking"
  project_name = var.project_name
}

# Provision the virtual instance via the Compute module
module "compute" {
  source                = "./modules/compute"
  project_name          = var.project_name
  region                = var.aws_region
  vpc_id                = module.network.output_details.id
  vpc_cidr_blocks       = [module.network.output_details.cidr_block]
  public_subnet_id      = module.network.output_details.public_subnet_id
  private_subnet_id     = module.network.output_details.private_subnet_id
  ec2_instance_type     = var.instance_type
  ami_id                = data.aws_ami.ubuntu.id
  s3_bucket_name        = module.storage.output_details.bucket_name
  # alb_logs_s3_bucket    = "${var.project_name}-alb-logs-bucket"
  # application_logs_name = "/${var.project_name}/application"
}

# Provisinion storage resources via Storage module
module "storage" {
  source             = "./modules/storage"
  project_name       = var.project_name
  bucket_name        = "${var.project_name}-bucket"
  alb_logs_s3_bucket = "${var.project_name}-alb-logs-bucket"
  vpc_id             = module.network.output_details.id
  private_subnet_ids = module.network.output_details.private_subnet_id
  application_sg_id  = module.compute.output_details.app_security_group_id
}

# Provision monitoring resources via Monitoring module
# module "monitoring" {
#   source             = "./modules/monitoring"
#   project_name       = var.project_name
#   vpc_id             = module.network.output_details.id
#   vpc_cidr_blocks    = [module.network.output_details.cidr_block]
#   application_sg_ids = [module.compute.output_details.app_security_group_id]
# }
