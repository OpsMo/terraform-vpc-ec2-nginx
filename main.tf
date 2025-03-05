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
  map_customer_owned_ip_on_launch = true

}   

resource "aws_subnet" "private" {
  count             = length(var.availability_zones)
  vpc_id           = aws_vpc.main.id
  cidr_block       = cidrsubnet(aws_vpc.main.cidr_block, 3, count.index + length(var.availability_zones))
  availability_zone = var.availability_zones[count.index]

}

