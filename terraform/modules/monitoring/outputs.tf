output "output_details" {
  description = "Details of monitoring resources created."
  value = {
    application   = aws_cloudwatch_log_group.application_logs.name
    access        = aws_cloudwatch_log_group.access_logs.name
    error         = aws_cloudwatch_log_group.error_logs.name
    system        = aws_cloudwatch_log_group.system_logs.name
    alb           = aws_cloudwatch_log_group.alb_access_logs[*].name
    cloudwatch_sg = aws_security_group.cloudwatch_agent_sg.id
  }
}
