# App Modules

# Create Public Subnet
resource "aws_subnet" "eng74_ben_public_subnet_terraform" {
  vpc_id     = var.vpc_id
  cidr_block = "108.21.1.0/24"
  # map_public_ip_on_launch = true

  tags = {
    Name = "${var.eng_class_person}subnet_public_terraform"
  }
}

# Public SG
resource "aws_security_group" "sg_app_vpc" {
  name        = "public_SG_for_app_instance"
  description = "Allows traffic to app"
  vpc_id      = var.vpc_id

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
    Name = "${var.eng_class_person}sg_app_terraform"
  }
}

# Public NACL
resource "aws_network_acl" "eng74_ben_terraform_nacl_public" {
  vpc_id = var.vpc_id
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
    Name = "${var.eng_class_person}nacl_public_terraform"
  }
}

# Route Table Public
resource "aws_route_table" "eng74_ben_route_public_terraform" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.gw_id
  }

  tags = {
    Name = "${var.eng_class_person}route_table_terraform"
  }
}

resource "aws_route_table_association" "public_subnet_assoc"{
	subnet_id = aws_subnet.eng74_ben_public_subnet_terraform.id
	route_table_id = aws_route_table.eng74_ben_route_public_terraform.id
}

resource "aws_instance" "nodejs_instance"{
        ami = var.nodejs_app
        subnet_id = aws_subnet.eng74_ben_public_subnet_terraform.id
        vpc_security_group_ids = [aws_security_group.sg_app_vpc.id]
	instance_type = "t2.micro"
	associate_public_ip_address = true
	tags = {
	    Name = "ben_eng74_nodeapp_version_2"
        }
	key_name = var.ssh_key
        user_data = <<-EOF
                #!/bin/bash
                cd /home/ubuntu/app
                DB_HOST=${var.db_ip} pm2 start app.js
                EOF
}