locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terragrunt"
  }

  tokyo_azs = ["${var.tokyo_region}a", "${var.tokyo_region}c"]
  taipei_azs = ["${var.taipei_region}a", "${var.taipei_region}b"]
}