variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for DB subnet group"
  type        = list(string)
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "db_username" {
  description = "Database username"
  type        = string
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
}

variable "common_tags" {
  description = "Common tags"
  type        = map(string)
}

resource "aws_security_group" "db" {
  vpc_id = var.vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"] # Allow from VPC
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "${var.region}-DB-SG"
  })
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.region}-db-subnet"
  subnet_ids = var.subnet_ids

  tags = merge(var.common_tags, {
    Name = "${var.region}-DB-Subnet"
  })
}

resource "aws_db_instance" "this" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = var.db_instance_class
  db_name              = "shoppingdb"
  username             = var.db_username
  password             = var.db_password
  parameter_group_name = "default.mysql8.0"
  db_subnet_group_name = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.db.id]
  multi_az             = true
  skip_final_snapshot  = true

  tags = merge(var.common_tags, {
    Name = "${var.region}-DB"
  })
}

output "db_endpoint" {
  value     = aws_db_instance.this.endpoint
  sensitive = true
}

output "db_sg_id" {
  value = aws_security_group.db.id
}