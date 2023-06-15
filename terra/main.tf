# Configure AWS provider
provider "aws" {
  region = "ap-south-1"  # Replace with your desired region
}

# Create VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = { 
    Name = "vpc0001"
  }
}

# Create public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"  # Replace with your desired availability zone
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet0001"
  }
}

# Create private subnet
resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-south-1a"  # Replace with your desired availability zone
  tags = {
    Name = "private-subnet0002"
  }
}

# Create security group for EC2 instance
resource "aws_security_group" "instance_sg1" {
  name        = "instance-sg1"
  description = "Security group for EC2 instance"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Replace with your desired source IP range
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "instance-sg1"
}
}

# Create EC2 instance
resource "aws_instance" "my_instance" {
  ami           = "ami-057752b3f1d6c4d6c"  # Replace with your desired AMI ID
  instance_type = "t2.micro"  # Replace with your desired instance type


  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.instance_sg1.id]

  user_data = <<-EOF
    #!/bin/bash
    echo "Hello, World!" > index.html
    nohup python -m SimpleHTTPServer 80 &
    EOF

  tags = {
    Name = "ec2instance-3"
  }
}
