provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  count      = length(var.availability_zones)
  cidr_block       = cidrsubnet(aws_vpc.main.cidr_block, 3, count.index)
  availability_zone = var.availability_zones[count.index]
  map_public_ip_on_launch = true
}   

resource "aws_subnet" "private" {
  count             = length(var.availability_zones)
  vpc_id           = aws_vpc.main.id
  cidr_block       = cidrsubnet(aws_vpc.main.cidr_block, 3, count.index + length(var.availability_zones))
  availability_zone = var.availability_zones[count.index]

}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route" "internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}

resource "aws_route_table_association" "public_assoc" {
  count          = length(var.availability_zones)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "http_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
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
resource "aws_instance" "ec2nginx" {
  ami           = var.ami_id
  tags = {
    Name = "nginx"
  }
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public[0].id
  security_groups = [aws_security_group.http_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y nginx
              systemctl start nginx
              systemctl enable nginx
              echo "<h1>Welcome to Ansys Demo</h1>" > /usr/share/nginx/html/index.html
              EOF
}

