output "tokyo_alb_dns" {
  description = "DNS name of Tokyo ALB"
  value       = module.networking_tokyo.alb_dns
}

output "taipei_alb_dns" {
  description = "DNS name of Taipei ALB"
  value       = module.networking_taipei.alb_dns
}

output "cloudfront_domain" {
  description = "CloudFront distribution domain"
  value       = aws_cloudfront_distribution.this.domain_name
}

output "tokyo_db_endpoint" {
  description = "Tokyo database endpoint"
  value       = module.database_tokyo.db_endpoint
  sensitive   = true
}

output "taipei_db_endpoint" {
  description = "Taipei database endpoint"
  value       = module.database_taipei.db_endpoint
  sensitive   = true
}

# ============================================================
# Observability Outputs
# ============================================================

output "sns_alerts_topic_arn" {
  description = "SNS topic ARN for observability alerts"
  value       = aws_sns_topic.observability_alerts.arn
}

output "cloudwatch_dashboard_url" {
  description = "URL to CloudWatch Dashboard"
  value       = "https://console.aws.amazon.com/cloudwatch/home?region=${var.tokyo_region}#dashboards:name=${aws_cloudwatch_dashboard.application_overview.dashboard_name}"
}

output "cloudtrail_s3_bucket" {
  description = "S3 bucket for CloudTrail logs"
  value       = aws_s3_bucket.cloudtrail_logs.id
}

output "cloudtrail_name" {
  description = "CloudTrail name"
  value       = aws_cloudtrail.main.name
}

output "vpc_flow_logs_log_group_tokyo" {
  description = "VPC Flow Logs CloudWatch log group for Tokyo"
  value       = aws_cloudwatch_log_group.vpc_flow_logs_tokyo.name
}

output "vpc_flow_logs_log_group_taipei" {
  description = "VPC Flow Logs CloudWatch log group for Taipei"
  value       = aws_cloudwatch_log_group.vpc_flow_logs_taipei.name
}

output "xray_sampling_rule" {
  description = "X-Ray sampling rule name"
  value       = aws_xray_sampling_rule.default.rule_name
}

output "application_log_group" {
  description = "Application logs CloudWatch log group"
  value       = aws_cloudwatch_log_group.application_logs.name
}

output "alb_log_group" {
  description = "ALB logs CloudWatch log group"
  value       = aws_cloudwatch_log_group.alb_logs.name
}

output "rds_log_group" {
  description = "RDS logs CloudWatch log group"
  value       = aws_cloudwatch_log_group.rds_logs.name
}