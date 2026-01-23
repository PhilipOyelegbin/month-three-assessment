output "output_details" {
  description = "Details of monitoring resources created."
  value = {
    application     = aws_cloudwatch_log_group.application_logs.name
    application_arn = aws_cloudwatch_log_group.application_logs.arn
    cloudwatch_sg   = aws_security_group.cloudwatch_agent_sg.id
  }
}
