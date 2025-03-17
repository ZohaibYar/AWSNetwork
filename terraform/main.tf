#starthere
provider "aws" {
  region = "us-east-1"
}

# =========================
# VPC Configuration
# =========================
resource "aws_vpc" "zohaib_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

# =========================
# Public Subnets
# =========================
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.zohaib_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.zohaib_vpc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1b"
}

# =========================
# Private Subnets
# =========================
resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.zohaib_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.zohaib_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b"
}

# =========================
# Internet Gateway
# =========================
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.zohaib_vpc.id
}

# =========================
# Security Group for EC2
# =========================
resource "aws_security_group" "web_sg" {
  vpc_id = aws_vpc.zohaib_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# =========================
# EC2 Instance
# =========================
resource "aws_instance" "web_server" {
  ami                    = "ami-08b5b3a93ed654d19"  
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_subnet_1.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  key_name               = "vockey"  

  tags = {
    Name = "WebServer"
  }
}
# =========================
# Public Route Table
# =========================
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.zohaib_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

# Associate Public Subnets with the Route Table
resource "aws_route_table_association" "public_subnet_1_assoc" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_subnet_2_assoc" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_rt.id
}
