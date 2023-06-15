provider "aws" {
  region = "ap-south-1"
}
resource "aws_vpc" "myVpc1" {
  cidr_block = "10.0.0.0/24"
}
data "aws_availability_zones" "available_zones" {}
resource "aws_subnet" "publicSubnet1" {
  vpc_id            = aws_vpc.myVpc1.id
  cidr_block        = "10.0.0.0/25"
  availability_zone = data.aws_availability_zones.available_zones.names[0]
  tags = {
    Name = "publicSubnet1"
  }
}
resource "aws_subnet" "privateSubnet1" {
  vpc_id            = aws_vpc.myVpc1.id
  cidr_block        = "10.0.0.128/25"
  availability_zone = data.aws_availability_zones.available_zones.names[1]
  tags = {
    Name = "privateSubnet1"
  }
}

resource "aws_internet_gateway" "myIGW1" {
  vpc_id = aws_vpc.myVpc1.id
  tags = {
    Name = "myIGW1"
  }
}
resource "aws_route_table" "myPublicRoute" {
  vpc_id = aws_vpc.myVpc1.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myIGW1.id
  }
  tags = {
    Name = "myRoute"
  }
}
// associate subnet with route table
resource "aws_route_table_association" "myPublicRouteAssociate" {
  subnet_id      = aws_subnet.publicSubnet1.id
  route_table_id = aws_route_table.myPublicRoute.id
}


resource "aws_security_group" "mySecureGrp" {
  name   = "mySecureGrp"
  vpc_id = aws_vpc.myVpc1.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
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
    //ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "mySecureGrp"
  }
}
resource "aws_instance" "myEc2Public" {
  ami                    = "ami-057752b3f1d6c4d6c"
  instance_type          = "t2.micro"
  key_name               = "terraform"
  subnet_id              = aws_subnet.publicSubnet1.id
  vpc_security_group_ids = [aws_security_group.mySecureGrp.id]
  associate_public_ip_address = true
  user_data              = <<-EOF
              #! /bin/bash
              echo "hello world!" > hello.txt
              sudo apt-get update -y
              sudo apt  install docker.io -y
              curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
              unzip awscliv2.zip
              sudo ./aws/install
              aws ecr-public get-login-password --region us-east-1 | sudo docker login --username AWS --password-stdin public.ecr.aws/b9c2h9h8
              sudo docker pull public.ecr.aws/b9c2h9h8/gayu_repo1:latest
              sudo docker run -d -p 8080:80 public.ecr.aws/b9c2h9h8/gayu_repo1:latest              
              EOF

  tags = {
    Name = "publicEc2"
  }
}
