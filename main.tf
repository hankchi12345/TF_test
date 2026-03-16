# S3 bucket for static assets and Terragrunt state
resource "aws_s3_bucket" "state_bucket" {
  bucket = "hank-terraform-test-2026-03-10"

  tags = merge(local.common_tags, {
    Name = "State-Bucket"
  })
}

resource "aws_s3_bucket_versioning" "state_bucket" {
  bucket = aws_s3_bucket.state_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# DynamoDB for state locking
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = local.common_tags
}

# VPC Modules
module "vpc_tokyo" {
  source      = "./modules/vpc"
  vpc_cidr    = var.vpc_cidr_tokyo
  region      = var.tokyo_region
  azs         = local.tokyo_azs
  common_tags = local.common_tags

  providers = {
    aws = aws.tokyo
  }
}

module "vpc_taipei" {
  source      = "./modules/vpc"
  vpc_cidr    = var.vpc_cidr_taipei
  region      = var.taipei_region
  azs         = local.taipei_azs
  common_tags = local.common_tags

  providers = {
    aws = aws.taipei
  }
}

# Database Modules
module "database_tokyo" {
  source            = "./modules/database"
  vpc_id            = module.vpc_tokyo.vpc_id
  subnet_ids        = module.vpc_tokyo.subnet_ids
  region            = var.tokyo_region
  db_username       = var.db_username
  db_password       = var.db_password
  db_instance_class = var.db_instance_class
  common_tags       = local.common_tags

  providers = {
    aws = aws.tokyo
  }
}

module "database_taipei" {
  source            = "./modules/database"
  vpc_id            = module.vpc_taipei.vpc_id
  subnet_ids        = module.vpc_taipei.subnet_ids
  region            = var.taipei_region
  db_username       = var.db_username
  db_password       = var.db_password
  db_instance_class = var.db_instance_class
  common_tags       = local.common_tags

  providers = {
    aws = aws.taipei
  }
}

# Web Modules
module "web_tokyo" {
  source           = "./modules/web"
  vpc_id           = module.vpc_tokyo.vpc_id
  subnet_ids       = module.vpc_tokyo.subnet_ids
  region           = var.tokyo_region
  ami_id           = data.aws_ami.amazon_linux_tokyo.id
  instance_type    = var.instance_type
  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity
  common_tags      = local.common_tags

  providers = {
    aws = aws.tokyo
  }
}

module "web_taipei" {
  source           = "./modules/web"
  vpc_id           = module.vpc_taipei.vpc_id
  subnet_ids       = module.vpc_taipei.subnet_ids
  region           = var.taipei_region
  ami_id           = data.aws_ami.amazon_linux_taipei.id
  instance_type    = var.instance_type
  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity
  common_tags      = local.common_tags

  providers = {
    aws = aws.taipei
  }
}

# Networking Modules (ALB)
module "networking_tokyo" {
  source    = "./modules/networking"
  vpc_id    = module.vpc_tokyo.vpc_id
  subnet_ids = module.vpc_tokyo.subnet_ids
  region    = var.tokyo_region
  web_sg_id = module.web_tokyo.web_sg_id
  asg_name  = module.web_tokyo.asg_name
  common_tags = local.common_tags

  providers = {
    aws = aws.tokyo
  }
}

module "networking_taipei" {
  source    = "./modules/networking"
  vpc_id    = module.vpc_taipei.vpc_id
  subnet_ids = module.vpc_taipei.subnet_ids
  region    = var.taipei_region
  web_sg_id = module.web_taipei.web_sg_id
  asg_name  = module.web_taipei.asg_name
  common_tags = local.common_tags

  providers = {
    aws = aws.taipei
  }
}

# CloudFront Distribution
resource "aws_cloudfront_distribution" "this" {
  origin {
    domain_name = module.networking_tokyo.alb_dns
    origin_id   = "tokyo-origin"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  origin {
    domain_name = module.networking_taipei.alb_dns
    origin_id   = "taipei-origin"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Shopping Website CDN"
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "tokyo-origin"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = local.common_tags
}