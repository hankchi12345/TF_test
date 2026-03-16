variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs"
  type        = list(string)
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "ami_id" {
  description = "AMI ID"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "min_size" {
  description = "Minimum size for ASG"
  type        = number
}

variable "max_size" {
  description = "Maximum size for ASG"
  type        = number
}

variable "desired_capacity" {
  description = "Desired capacity for ASG"
  type        = number
}

variable "common_tags" {
  description = "Common tags"
  type        = map(string)
}

resource "aws_security_group" "web" {
  vpc_id = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "${var.region}-Web-SG"
  })
}

resource "aws_launch_template" "this" {
  name_prefix   = "${var.region}-web-lt-"
  image_id      = var.ami_id
  instance_type = var.instance_type

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.web.id]
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Shopping Website - ${var.region}</h1>" > /var/www/html/index.html
              EOF
  )

  tags = merge(var.common_tags, {
    Name = "${var.region}-Web-LT"
  })
}

resource "aws_autoscaling_group" "this" {
  desired_capacity  = var.desired_capacity
  max_size          = var.max_size
  min_size          = var.min_size
  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }
  vpc_zone_identifier = var.subnet_ids

  tag {
    key                 = "Name"
    value               = "${var.region}-Web-ASG"
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = var.common_tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}

output "asg_name" {
  value = aws_autoscaling_group.this.name
}

output "web_sg_id" {
  value = aws_security_group.web.id
}