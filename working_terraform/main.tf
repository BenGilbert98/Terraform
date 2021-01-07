# Which Cloud Provider is required
# - AWS as we have our AMI's on AWS

# Create VPC
resource "aws_vpc" "eng74_ben_terraform_vpc" {
  cidr_block       = "108.21.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "eng74_ben_vpc_terraform"
  }
}

# IGW
resource "aws_internet_gateway" "eng74_ben_igw_terraform" {
  #reference vpc_id dynamically by 
  #calling the resource, 
  #followed by the name of the resource, 
  #followed by the parameter you want 
  vpc_id = var.vpc_id

  tags = {
    Name = "eng74_ben_igw_terraform"
  }
}

resource "aws_route_table_association" "route_public_association" {
  subnet_id      = var.subnet_id
  route_table_id = var.route_id
}

# Create Private Subnet
resource "aws_subnet" "eng74_ben_private_subnet_terraform" {
  vpc_id     = var.vpc_id
  cidr_block = "108.21.2.0/24"
  # map_public_ip_on_launch = true

  tags = {
    Name = "eng74_ben_subnet_private_terraform"
  }
}

# Private NACL
resource "aws_network_acl" "eng74_ben_terraform_nacl_private" {
  vpc_id = var.vpc_id
  subnet_ids = [aws_subnet.eng74_ben_private_subnet_terraform.id]
  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "108.21.1.0/24"
    from_port  = 27017
    to_port    = 27017
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  tags = {
    Name = "eng74_ben_nacl_private_terraform"
  }
}

# Private SG
resource "aws_security_group" "sg_db_vpc" {
  name        = "private_SG_for_db_instance"
  description = "Allows traffic to db from app"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allows 27017 from app"
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    security_groups = [aws_security_group.sg_app_vpc.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "eng74_ben_sg_db_terraform"
  }
}

# Creating EC2 instances
provider "aws" {
        region = var.region 
}

resource "aws_instance" "nodejs_db_instance"{
        ami = var.ami_db
        subnet_id = aws_subnet.eng74_ben_private_subnet_terraform.id
        vpc_security_group_ids = [aws_security_group.sg_db_vpc.id]
        instance_type = var.instance
        associate_public_ip_address = true
        tags = {
            Name = "ben_eng74_nodeapp_db"
        }
        key_name = var.key_name
}

# call the app module

module "app" {
  source = "./modules/app_tier"
  vpc_id = aws_vpc.eng74_ben_terraform_vpc.id
  subnet_id = aws_subnet.eng74_ben_public_subnet_terraform.id
  igw_id = aws_internet_gateway.eng74_ben_igw_terraform.id
  route_id = aws_route_table.eng74_ben_route_public_terraform.id
}