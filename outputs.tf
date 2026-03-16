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