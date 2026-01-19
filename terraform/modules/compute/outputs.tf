output "output_details" {
  description = "Details of compute resources created."
  value = {
    lt_id                 = aws_launch_template.api-lt.id
    asg_id                = aws_autoscaling_group.api-asg.id
    asg_public_ips        = data.aws_instances.asg_instances.public_ips
    app_security_group_id = aws_security_group.application_sg.id
    alb                   = aws_lb.app-lb.dns_name
  }
}