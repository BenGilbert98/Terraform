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
  vpc_id = aws_vpc.eng74_ben_terraform_vpc.id

  tags = {
    Name = "eng74_ben_igw_terraform"
  }
}

# Create Public Subnet
resource "aws_subnet" "eng74_ben_public_subnet_terraform" {
  vpc_id     = aws_vpc.eng74_ben_terraform_vpc.id
  cidr_block = "108.21.1.0/24"
  # map_public_ip_on_launch = true

  tags = {
    Name = "eng74_ben_subnet_public_terraform"
  }
}

# Public SG
resource "aws_security_group" "sg_app_vpc" {
  name        = "public_SG_for_app_instance"
  description = "Allows traffic to app"
  vpc_id      = aws_vpc.eng74_ben_terraform_vpc.id

  ingress {
    description = "Allows HTTPS from everywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allows HTTP from everywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

   ingress {
    description = "Allows port 3000 from my ip"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["90.218.243.127/32"]
  } 
   
   ingress {
    description = "Allows port 22 from my ip"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["90.218.243.127/32"]
  } 
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "eng74_ben_sg_app_terraform"
  }
}
# Public NACL
resource "aws_network_acl" "eng74_ben_terraform_nacl_public" {
  vpc_id = aws_vpc.eng74_ben_terraform_vpc.id
  subnet_ids = [aws_subnet.eng74_ben_public_subnet_terraform.id]
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
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 120
    action     = "allow"
    cidr_block = "90.218.243.127/32"
    from_port  = 22
    to_port    = 22
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 130
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  tags = {
    Name = "eng74_ben_nacl_public_terraform"
  }
}

# Route Table Public
resource "aws_route_table" "eng74_ben_route_public_terraform" {
  vpc_id = aws_vpc.eng74_ben_terraform_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eng74_ben_igw_terraform.id
  }

  tags = {
    Name = "eng74_ben_route_table_terraform"
  }
}

resource "aws_route_table_association" "route_public_association" {
  subnet_id      = aws_subnet.eng74_ben_public_subnet_terraform.id
  route_table_id = aws_route_table.eng74_ben_route_public_terraform.id
}

# Create Private Subnet
resource "aws_subnet" "eng74_ben_private_subnet_terraform" {
  vpc_id     = aws_vpc.eng74_ben_terraform_vpc.id
  cidr_block = "108.21.2.0/24"
  # map_public_ip_on_launch = true

  tags = {
    Name = "eng74_ben_subnet_private_terraform"
  }
}

# Private NACL
resource "aws_network_acl" "eng74_ben_terraform_nacl_private" {
  vpc_id = aws_vpc.eng74_ben_terraform_vpc.id
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
  vpc_id      = aws_vpc.eng74_ben_terraform_vpc.id

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

resource "aws_instance" "nodejs_instance"{
        ami = var.ami_app
        subnet_id = aws_subnet.eng74_ben_public_subnet_terraform.id
        vpc_security_group_ids = [aws_security_group.sg_app_vpc.id]
	instance_type = var.instance
	associate_public_ip_address = true
	tags = {
	    Name = "ben_eng74_nodeapp_version_2"
        }
	key_name = var.key_name
        depends_on = [ 
                aws_instance.nodejs_db_instance,
         ]
        user_data = <<-EOF
                #!/bin/bash
                cd /home/ubuntu/app
                DB_HOST=${aws_instance.nodejs_db_instance.private_ip} pm2 start app.js
                EOF
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

