variable "db_username" {
  description = "Database username"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
  default     = "password123" # In production, use AWS Secrets Manager
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "shopping-site"
}

variable "tokyo_region" {
  description = "Tokyo region"
  type        = string
  default     = "ap-northeast-1"
}

variable "taipei_region" {
  description = "Taipei region"
  type        = string
  default     = "ap-northeast-3"
}

variable "vpc_cidr_tokyo" {
  description = "VPC CIDR for Tokyo"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_cidr_taipei" {
  description = "VPC CIDR for Taipei"
  type        = string
  default     = "10.1.0.0/16"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "min_size" {
  description = "Minimum size for ASG"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum size for ASG"
  type        = number
  default     = 10
}

variable "desired_capacity" {
  description = "Desired capacity for ASG"
  type        = number
  default     = 2
}

# ============================================================
# Observability Variables
# ============================================================

variable "alert_email" {
  description = "Email address for observability alerts"
  type        = string
  default     = "devops@example.com"
}

variable "log_retention_days" {
  description = "CloudWatch log retention period in days"
  type        = number
  default     = 30
}

variable "enable_vpc_flow_logs" {
  description = "Enable VPC Flow Logs"
  type        = bool
  default     = true
}

variable "enable_cloudtrail" {
  description = "Enable CloudTrail for API auditing"
  type        = bool
  default     = true
}

variable "enable_xray" {
  description = "Enable AWS X-Ray for distributed tracing"
  type        = bool
  default     = true
}

variable "xray_sampling_rate" {
  description = "X-Ray sampling rate (0.0 to 1.0)"
  type        = number
  default     = 0.1
}