#============================================ SSH Key Pair ============================================#
resource "aws_key_pair" "deployer" {
  key_name   = "${var.project_name}-key"
  public_key = file("${path.root}/id_rsa.pub")
}

#============================================ Security Group ============================================#
# Application/Backend Security Group
resource "aws_security_group" "application_sg" {
  name        = "${var.project_name}-application_sg"
  description = "Security group for backend application instances"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  ingress {
    description     = "HTTPS from ALB"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  ingress {
    description = "ICMP for troubleshooting"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = var.vpc_cidr_blocks
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-application_sg"
  }
}

# Application Load Balancer Security Group
resource "aws_security_group" "alb_sg" {
  name        = "${var.project_name}-alb-sg"
  description = "Security group for Application Load Balancer"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS access"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-alb-sg"
  }
}

#============================================ Load Balancer ============================================#
# Creating an application load balancer
resource "aws_lb" "app-lb" {
  name                       = "${var.project_name}-app-lb"
  internal                   = false
  load_balancer_type         = "application"
  subnets                    = var.public_subnet_id
  security_groups            = [aws_security_group.alb_sg.id]
  enable_deletion_protection = false

  access_logs {
    bucket  = var.alb_logs_bucket_name
    prefix  = "alb-logs"
    enabled = true
  }

  tags = {
    Name = "${var.project_name}-app-lb"
  }
}

# Creating a target group for the api servers
resource "aws_lb_target_group" "api-tg" {
  name     = "${var.project_name}-api-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/health"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 60
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "${var.project_name}-api-tg"
  }
}

# Creating a listener for the load balancer
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app-lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api-tg.arn
  }
}

#============================================ Autoscaling ============================================#
# Creating launch template for the api servers
resource "aws_launch_template" "api-lt" {
  name_prefix   = "${var.project_name}-api-lt"
  image_id      = var.ami_id
  instance_type = var.ec2_instance_type
  key_name      = aws_key_pair.deployer.key_name

  vpc_security_group_ids = [aws_security_group.application_sg.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_log_profile.name
  }

  user_data = base64encode(templatefile("${path.module}/user-data.sh", {
    project_name         = var.project_name
    cloudwatch_log_group = var.application_logs_name
    region               = var.region
  }))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.project_name}-api-instance"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Creating auto scaling group for the api servers
resource "aws_autoscaling_group" "api-asg" {
  name_prefix         = "${var.project_name}-api-asg"
  min_size            = 1
  max_size            = 2
  desired_capacity    = 1
  vpc_zone_identifier = var.public_subnet_id
  target_group_arns   = [aws_lb_target_group.api-tg.arn]

  launch_template {
    id      = aws_launch_template.api-lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-api-asg"
    propagate_at_launch = true
  }

  # Health check configuration
  health_check_type         = "ELB"
  health_check_grace_period = 300

  lifecycle {
    create_before_destroy = true
  }
}

# Data source to get current ASG instances
data "aws_instances" "asg_instances" {
  filter {
    name   = "tag:aws:autoscaling:groupName"
    values = [aws_autoscaling_group.api-asg.name]
  }

  depends_on = [aws_autoscaling_group.api-asg]
}

#============================================ IAM Roles & Policies ============================================#
# IAM role for EC2 instances
resource "aws_iam_role" "ec2_role" {
  name = "${var.project_name}-EC2CloudWatchLoggingRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-ec2-role"
  }
}

# Attach the managed policy for CloudWatch Agent
resource "aws_iam_role_policy_attachment" "cw_agent_attach" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# Create the Instance Profile (to be used in your ASG Launch Template)
resource "aws_iam_instance_profile" "ec2_log_profile" {
  name = "${var.project_name}-EC2CloudWatchInstanceProfile"
  role = aws_iam_role.ec2_role.name
}

# AWS Managed Policy for SSM Access
resource "aws_iam_role_policy_attachment" "ssm_core" {
  count      = var.enable_ssm_access ? 1 : 0
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
