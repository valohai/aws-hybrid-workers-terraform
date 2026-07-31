

data "aws_availability_zones" "available" {}

# VPC
resource "aws_vpc" "valohai-vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true

  tags = {
    Name    = "valohai-vpc"
  }
}

locals {
  az_count    = length(data.aws_availability_zones.available.names)
  subnet_bits = ceil(log(local.az_count, 2))
}

# Subnet per availability zone
resource "aws_subnet" "valohai_subnets" {
  count                   = local.az_count
  vpc_id                  = aws_vpc.valohai-vpc.id
  cidr_block              = cidrsubnet(aws_vpc.valohai-vpc.cidr_block, local.subnet_bits, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name    = "valohai-subnet-${1 + count.index}",
  }
}

# Internet Gateway
resource "aws_internet_gateway" "valohai-igw" {
  vpc_id = aws_vpc.valohai-vpc.id
  tags = {
    "Name"  = "valohai-igw"
  }
}

# RouteTable
data "aws_route_table" "valohai-rt" {
  vpc_id = aws_vpc.valohai-vpc.id
}

resource "aws_route" "route" {
  route_table_id         = data.aws_route_table.valohai-rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.valohai-igw.id
}

# Security Groups
resource "aws_security_group" "valohai-sg-workers" {
  name        = "valohai-sg-workers"
  description = "for Valohai workers"
  vpc_id      = aws_vpc.valohai-vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "valohai-sg-workers"
  }
}

resource "aws_security_group" "valohai-sg-queue" {
  name        = "valohai-sg-queue"
  description = "for Valohai queue"
  vpc_id      = aws_vpc.valohai-vpc.id

  ingress {
    description = "for ACME tooling and LetsEncrypt challenge"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }

  ingress {
    description = "for Redis over SSL from app.valohai.com"
    cidr_blocks = ["34.248.245.191/32"]
    from_port   = 63790
    to_port     = 63790
    protocol    = "tcp"
  }

  ingress {
    description     = "for Redis over SSL from Valohai workers"
    security_groups = [aws_security_group.valohai-sg-workers.id]
    from_port       = 63790
    to_port         = 63790
    protocol        = "tcp"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "valohai-sg-queue"
  }
}
