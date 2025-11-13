# main.tf - Defines the core network infrastructure for the CloudNorth EKS Cluster

# ==============================================================================
# 1. PROVIDER & VARIABLES
# ==============================================================================
provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  description = "The AWS region where resources will be created."
  type        = string
  default     = "us-east-1"
}

# ==============================================================================
# 2. VPC (VIRTUAL PRIVATE CLOUD)
# This is the main network container for all our resources.
# ==============================================================================
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "cloudnorth-vpc"
  }
}

# ==============================================================================
# 3. INTERNET GATEWAY & PUBLIC ROUTING
# To provide internet access to the public subnets.
# ==============================================================================
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "cloudnorth-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "cloudnorth-public-rt"
  }
}

# ==============================================================================
# 4. PUBLIC SUBNETS
# For resources that need direct internet access (e.g., Load Balancers).
# ==============================================================================
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true # Instances here get a public IP

  tags = {
    Name = "cloudnorth-public-subnet-a"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "${var.aws_region}b"
  map_public_ip_on_launch = true

  tags = {
    Name = "cloudnorth-public-subnet-b"
  }
}

# Associate the public route table with our public subnets
resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}

# ==============================================================================
# 5. NAT GATEWAY & PRIVATE ROUTING
# To allow resources in private subnets to access the internet outbound.
# ==============================================================================
resource "aws_eip" "nat" {
  depends_on = [aws_internet_gateway.main] # Ensures IGW is created first

  tags = {
    Name = "cloudnorth-nat-eip"
  }
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_a.id # Place the NAT gateway in a public subnet

  tags = {
    Name = "cloudnorth-nat-gw"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name = "cloudnorth-private-rt"
  }
}

# ==============================================================================
# 6. PRIVATE SUBNETS
# For our secure backend resources (EKS worker nodes).
# ==============================================================================
resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.101.0/24"
  availability_zone = "${var.aws_region}a"

  tags = {
    Name = "cloudnorth-private-subnet-a"
  }
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.102.0/24"
  availability_zone = "${var.aws_region}b"

  tags = {
    Name = "cloudnorth-private-subnet-b"
  }
}

# Associate the private route table with our private subnets
resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private.id
}
