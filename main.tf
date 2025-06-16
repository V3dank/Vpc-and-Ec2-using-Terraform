provider "aws" {
  region  = var.aws_region
  profile = "default"
}

# VPC
resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr_block
  instance_tenancy = "default"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = merge({
    Name    = var.vpc_name,
    Creator = var.vpc_creator
  },
    var.additionalatags
  )
}

# Subnets (dynamic creation)
resource "aws_subnet" "subnets" {
  for_each = var.subnets

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = each.value.public

  tags = {
    Name = "terraform-${each.key}"
  }
}

# IGW
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = var.igw_name
  }
}

# Elastic IP for NAT
resource "aws_eip" "nat_eip" {
  depends_on = [aws_internet_gateway.igw]
}

# NAT Gateway in first public subnet
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.subnets["public-subnet-01"].id
  depends_on    = [aws_eip.nat_eip]

  tags = {
    Name = "NatGateway"
  }
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = var.Public_RT_cidr
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = var.Public_RT_name
  }
}

# Associate Public Subnets
resource "aws_route_table_association" "public_associations" {
  for_each = {
    for k, v in var.subnets : k => v if v.public
  }

  subnet_id      = aws_subnet.subnets[each.key].id
  route_table_id = aws_route_table.public.id
}

# Private Route Table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = var.Private_RT_cidr
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = var.Priavte_RT_name
  }
}



# EC2 instance in public subnet
resource "aws_instance" "web" {
  ami                    = var.ec2_ami
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.subnets["public-subnet-01"].id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  key_name               = var.key_name 

  tags = {
    Name = var.instance_name
  }
}



# Associate Private Subnets
resource "aws_route_table_association" "private_associations" {
  for_each = {
    for k, v in var.subnets : k => v if v.public == false
  }

  subnet_id      = aws_subnet.subnets[each.key].id
  route_table_id = aws_route_table.private.id
}

# Security Group
resource "aws_security_group" "ec2_sg" {
  name        = var.SG_name
  description = "Security Group using Terraform"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = var.SG_name
  }
}

# Ingress rules loop
resource "aws_vpc_security_group_ingress_rule" "ingress" {
  for_each = { for idx, rule in var.ingress_rules : idx => rule }

  security_group_id = aws_security_group.ec2_sg.id
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  ip_protocol       = each.value.protocol
  cidr_ipv4         = each.value.cidr_blocks[0]
  description       = each.value.description
}

# Egress rules loop
resource "aws_vpc_security_group_egress_rule" "egress" {
  for_each = { for idx, rule in var.egress_rules : idx => rule }

  security_group_id = aws_security_group.ec2_sg.id
  ip_protocol       = each.value.protocol
  cidr_ipv4         = each.value.cidr_blocks[0]
  description       = each.value.description
}

