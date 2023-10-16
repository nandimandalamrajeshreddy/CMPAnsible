############## AWS  VPC ##############

resource "aws_vpc" "k8main" {
  cidr_block           = var.cidr_block_var["main_cidr"]
  instance_tenancy     = var.inst_tenancy
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "k8s-vpc"
  }
}

########## AWS Subnet ############
resource "aws_subnet" "k8publicsubnet" {
  vpc_id                  = aws_vpc.k8main.id
  cidr_block              = var.cidr_block_var["public_cidr"]
  map_public_ip_on_launch = var.map_public_ip
  availability_zone       = var.az_zone["useast1c"]
  tags = {
    Name = "k8s-publicsubnet"
  }
}
########## AWS Subnet ############
resource "aws_subnet" "k8publicsubnet1" {
  vpc_id                  = aws_vpc.k8main.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = var.az_zone["useast1a"]
  map_public_ip_on_launch = var.map_public_ip
  tags = {
    Name = "k8s-publicsubnet1"
  }
}
resource "aws_subnet" "k8privatesubnet" {
  vpc_id                  = aws_vpc.k8main.id
  cidr_block              = var.cidr_block_var["private_subnet"]
  map_public_ip_on_launch = "false"
  tags = {
    Name = "k8s-privatesubnet"
  }
}

########### AWS IGW ############
resource "aws_internet_gateway" "k8igw" {
  vpc_id = aws_vpc.k8main.id

  tags = {
    Name = "k8s-igw"
  }
}

############ AWS Route Table for k8publicsubnet#########
resource "aws_route_table" "k8rpsubnet" {
  vpc_id = aws_vpc.k8main.id

  route {
    cidr_block = var.cidr_block_var["route_subnet"]
    gateway_id = aws_internet_gateway.k8igw.id
  }

  tags = {
    Name = "k8-rpsubnet"
  }
}

############ AWS Route Table for k8publicsubnet#########
resource "aws_route_table" "k8rpsubnet1" {
  vpc_id = aws_vpc.k8main.id

  route {
    cidr_block = var.cidr_block_var["route_subnet"]
    gateway_id = aws_internet_gateway.k8igw.id
  }

  tags = {
    Name = "k8-rpsubnet1"
  }
}

############# AWS ROUTE TABLE ASSCN ##########
resource "aws_route_table_association" "k8routeasscn" {
  subnet_id      = aws_subnet.k8publicsubnet.id
  route_table_id = aws_route_table.k8rpsubnet.id
}

############# AWS ROUTE TABLE ASSCN 1 ##########
resource "aws_route_table_association" "k8routeasscn1" {
  subnet_id      = aws_subnet.k8publicsubnet1.id
  route_table_id = aws_route_table.k8rpsubnet1.id
}

