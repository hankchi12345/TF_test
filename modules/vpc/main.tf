variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "azs" {
  description = "Availability zones"
  type        = list(string)
}

variable "common_tags" {
  description = "Common tags"
  type        = map(string)
}

resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr
  tags = merge(var.common_tags, {
    Name = "${var.region}-VPC"
  })
}

resource "aws_subnet" "public" {
  count             = length(var.azs)
  vpc_id            = aws_vpc.this.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone = var.azs[count.index]
  tags = merge(var.common_tags, {
    Name = "${var.region}-Subnet-${count.index + 1}"
  })
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags = merge(var.common_tags, {
    Name = "${var.region}-IGW"
  })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = merge(var.common_tags, {
    Name = "${var.region}-RT"
  })
}

resource "aws_route_table_association" "public" {
  count          = length(var.azs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

output "vpc_id" {
  value = aws_vpc.this.id
}

output "subnet_ids" {
  value = aws_subnet.public[*].id
}

output "igw_id" {
  value = aws_internet_gateway.this.id
}