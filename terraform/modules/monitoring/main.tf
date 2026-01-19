#============================================ CloudWatch Log Groups ============================================#
# Application logs
resource "aws_cloudwatch_log_group" "application_logs" {
  name              = "/${var.project_name}/application"
  retention_in_days = var.log_retention_days

  tags = {
    Name = "${var.project_name}-app-logs"
  }
}

# Nginx/Access logs
resource "aws_cloudwatch_log_group" "access_logs" {
  name              = "/${var.project_name}/nginx/access"
  retention_in_days = var.log_retention_days

  tags = {
    Name = "${var.project_name}-access-logs"
  }
}

# Error logs
resource "aws_cloudwatch_log_group" "error_logs" {
  name              = "/${var.project_name}/nginx/error"
  retention_in_days = var.log_retention_days

  tags = {
    Name = "${var.project_name}-error-logs"
  }
}

# System logs
resource "aws_cloudwatch_log_group" "system_logs" {
  name              = "/${var.project_name}/system"
  retention_in_days = var.log_retention_days

  tags = {
    Name = "${var.project_name}-system-logs"
  }
}

# Load Balancer access logs
resource "aws_cloudwatch_log_group" "alb_access_logs" {
  count             = var.enable_alb_access_logs ? 1 : 0
  name              = "/aws/alb/${var.project_name}-alb"
  retention_in_days = var.alb_log_retention_days

  tags = {
    Name = "${var.project_name}-alb-access-logs"
  }
}

#============================================ Security Groups ============================================#
# CloudWatch Agent Security Group
resource "aws_security_group" "cloudwatch_agent_sg" {
  name        = "${var.project_name}-cloudwatch-agent-sg"
  description = "Security group for CloudWatch agent communication"
  vpc_id      = var.vpc_id

  ingress {
    description     = "CloudWatch agent from instances"
    from_port       = 25888
    to_port         = 25888
    protocol        = "tcp"
    security_groups = var.application_sg_ids
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-cloudwatch-agent-sg"
  }
}