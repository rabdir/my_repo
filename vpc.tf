provider "aws" {
  region = "us-east-1"  # Change this to your desired AWS region
}

resource "aws_vpc" "main" {
  cidr_block             = "10.0.0.0/16"
  enable_dns_support     = true
  enable_dns_hostnames   = true

  tags = {
    Name = "3-tier-app-vpc"
  }
}

resource "aws_subnet" "public_subnet1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1b"  # Change this to your desired availability zone

  tags = {
    Name = "public-subnet1"
  }
}

resource "aws_subnet" "public_subnet2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.3.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"  # Change this to your desired availability zone

  tags = {
    Name = "public-subnet2"
  }
}


resource "aws_internet_gateway" "nginx_igw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "private-route-table"
  }
}

resource "aws_route" "nginx_internet_route" {
  route_table_id         = aws_route_table.private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.nginx_igw.id
}
