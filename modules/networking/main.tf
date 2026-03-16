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

variable "web_sg_id" {
  description = "Web security group ID"
  type        = string
}

variable "asg_name" {
  description = "Auto Scaling Group name"
  type        = string
}

variable "common_tags" {
  description = "Common tags"
  type        = map(string)
}

resource "aws_lb" "this" {
  name               = "${var.region}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.web_sg_id]
  subnets            = var.subnet_ids

  tags = merge(var.common_tags, {
    Name = "${var.region}-ALB"
  })
}

resource "aws_lb_target_group" "this" {
  name     = "${var.region}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path = "/"
  }

  tags = merge(var.common_tags, {
    Name = "${var.region}-TG"
  })
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

resource "aws_autoscaling_attachment" "this" {
  autoscaling_group_name = var.asg_name
  lb_target_group_arn    = aws_lb_target_group.this.arn
}

output "alb_dns" {
  value = aws_lb.this.dns_name
}

output "alb_arn" {
  value = aws_lb.this.arn
}

output "target_group_arn" {
  value = aws_lb_target_group.this.arn
}