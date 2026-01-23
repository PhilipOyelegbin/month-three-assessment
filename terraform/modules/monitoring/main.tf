#============================================ CloudWatch Log Groups ============================================#
# Application logs
resource "aws_cloudwatch_log_group" "application_logs" {
  name              = "/${var.project_name}/application"
  retention_in_days = var.log_retention_days

  tags = {
    Name        = "${var.project_name}-app-logs"
    Application = "backend"
  }
}

# Consolidated App/Nginx Logs
resource "aws_cloudwatch_log_group" "nginx_logs" {
  for_each          = toset(["access", "error"])
  name              = "/${var.project_name}/nginx/${each.key}"
  retention_in_days = var.log_retention_days
  log_group_class   = "INFREQUENT_ACCESS"
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

#============================================ Cloudwatch Dashboard ============================================#
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.project_name}-ApplicationMonitoring"
  dashboard_body = templatefile("../${path.root}/monitoring/cloudwatch-dashboard.json", {
    project_name = var.project_name
    region       = var.region
  })
}

locals {
  alarms = jsondecode(file("../${path.root}/monitoring/alarm-definitions.json"))
}

resource "aws_cloudwatch_metric_alarm" "app_alarms" {
  for_each = { for a in local.alarms : a.alarm_name => a }

  alarm_name          = "${var.project_name}-${each.value.alarm_name}"
  comparison_operator = each.value.comparison_operator
  evaluation_periods  = each.value.evaluation_periods
  metric_name         = each.value.metric_name
  namespace           = each.value.namespace
  period              = each.value.period
  statistic           = each.value.statistic
  threshold           = each.value.threshold
  # alarm_actions       = [var.sns_topic_arn]
}
