# remote_state {
#   backend = "s3"
#   config = {
#     bucket         = "hank-terraform-test-2026-03-10"
#     key            = "${path_relative_to_include()}/terraform.tfstate"
#     region         = "ap-northeast-1"
#     encrypt        = true
#     dynamodb_table = "terraform-locks"
#   }
# }

generate "provider" {
  path = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1" # 東京
  alias  = "tokyo"
}

provider "aws" {
  region = "ap-northeast-3" # 台北
  alias  = "taipei"
}
EOF
}

generate "data" {
  path = "data.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
# Data source for latest Amazon Linux 2 AMI in Tokyo
data "aws_ami" "amazon_linux_tokyo" {
  provider    = aws.tokyo
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Data source for latest Amazon Linux 2 AMI in Taipei
data "aws_ami" "amazon_linux_taipei" {
  provider    = aws.taipei
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}
EOF
}