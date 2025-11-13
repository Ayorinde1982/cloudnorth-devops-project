# Create Security Group for EC2 Instances
resource "aws_security_group" "ec2_sg" {
  name        = "${var.instance_name}-sg"
  description = "Security group for ${var.instance_name}"
  vpc_id      = var.vpc_id

  # SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH access"
  }

  # Jenkins access (if it's a Jenkins server)
  dynamic "ingress" {
    for_each = var.is_jenkins ? [1] : []
    content {
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Jenkins web interface"
    }
  }

  # Outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.instance_name}-sg"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Create EC2 Instance
resource "aws_instance" "main" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.key_pair_name
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  subnet_id              = var.public_subnets[0]

  # Root volume
  root_block_device {
    volume_size = 20
    volume_type = "gp2"
    encrypted   = true
  }

  tags = {
    Name        = var.instance_name
    Environment = var.environment
    Project     = var.project_name
    Role        = var.is_jenkins ? "jenkins-server" : "bastion-host"
  }

  # User data script for Jenkins server
  user_data = var.is_jenkins ? file("${path.module}/user-data/jenkins-setup.sh") : ""
}

# Get latest Ubuntu AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Create Elastic IP for the instance
resource "aws_eip" "main" {
  instance = aws_instance.main.id
  domain   = "vpc"

  tags = {
    Name        = "${var.instance_name}-eip"
    Environment = var.environment
    Project     = var.project_name
  }
}

output "instance_id" {
  value = aws_instance.main.id
}

output "public_ip" {
  value = aws_eip.main.public_ip
}

output "public_dns" {
  value = aws_instance.main.public_dns
}
