provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "cloudnorth_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "cloudnorth-vpc"
  }
}

resource "aws_internet_gateway" "cloudnorth_igw" {
  vpc_id = aws_vpc.cloudnorth_vpc.id
  tags = {
    Name = "cloudnorth-igw"
  }
}

resource "aws_subnet" "cloudnorth_subnet_1" {
  vpc_id            = aws_vpc.cloudnorth_vpc.id
  cidr_block        = "10.0.10.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "cloudnorth-subnet-1"
  }
}

resource "aws_subnet" "cloudnorth_subnet_2" {
  vpc_id            = aws_vpc.cloudnorth_vpc.id
  cidr_block        = "10.0.20.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "cloudnorth-subnet-2"
  }
}

resource "aws_security_group" "cloudnorth_sg" {
  name        = "cloudnorth-sg"
  description = "Allow SSH, HTTP, and HTTPS"
  vpc_id      = aws_vpc.cloudnorth_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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

  tags = {
    Name = "cloudnorth-sg"
  }
}

resource "aws_instance" "frontend" {
  ami                         = "ami-0c02fb55956c7d316" # Amazon Linux 2 AMI (us-east-1)
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.cloudnorth_subnet_1.id
  vpc_security_group_ids      = [aws_security_group.cloudnorth_sg.id]
  associate_public_ip_address = true
  tags = {
    Name = "cloudnorth-frontend"
  }
}

resource "aws_instance" "backend" {
  ami                         = "ami-0c02fb55956c7d316"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.cloudnorth_subnet_1.id
  vpc_security_group_ids      = [aws_security_group.cloudnorth_sg.id]
  associate_public_ip_address = true
  tags = {
    Name = "cloudnorth-backend"
  }
}

resource "random_id" "bucket_id" {
  byte_length = 4
}

resource "aws_s3_bucket" "static_content" {
  bucket = "cloudnorth-static-content-${random_id.bucket_id.hex}"
  tags = {
    Name = "cloudnorth-static-content"
  }
}

resource "aws_db_subnet_group" "cloudnorth_db_subnet_group" {
  name       = "cloudnorth-db-subnet-group"
  subnet_ids = [
    aws_subnet.cloudnorth_subnet_1.id,
    aws_subnet.cloudnorth_subnet_2.id
  ]
  tags = {
    Name = "cloudnorth-db-subnet-group"
  }
}

resource "aws_db_instance" "cloudnorth_db" {
  allocated_storage      = 20
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  db_name                = "cloudnorthdb"
  username               = "admin"
  password               = "CloudNorth123!"
  parameter_group_name   = "default.mysql8.0"
  skip_final_snapshot    = true
  publicly_accessible    = true
  vpc_security_group_ids = [aws_security_group.cloudnorth_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.cloudnorth_db_subnet_group.name
  tags = {
    Name = "cloudnorth-db"
  }
}
