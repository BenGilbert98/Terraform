# Create Private Subnet
resource "aws_subnet" "eng74_ben_private_subnet_terraform" {
  vpc_id     = var.vpc_id_db
  cidr_block = "108.21.2.0/24"
  # map_public_ip_on_launch = true

  tags = {
    Name = "${var.eng_class_person}subnet_private_terraform"
  }
}

# Private NACL
resource "aws_network_acl" "eng74_ben_terraform_nacl_private" {
  vpc_id = var.vpc_id_db
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
    Name = "${var.eng_class_person}nacl_private_terraform"
  }
}

# Private SG
resource "aws_security_group" "sg_db_2" {
  name        = "private_SG_for_db_instance"
  description = "Allows traffic to db from app"
  vpc_id      = var.vpc_id_db

  ingress {
    description = "Allows 27017 from app"
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    security_groups = [var.app_sg_id] # How to get an output from a module
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.eng_class_person}sg_db_terraform"
  }
}

# Creating EC2 instances
resource "aws_instance" "nodejs_db_instance"{
        ami = var.nodejs_db
        subnet_id = aws_subnet.eng74_ben_private_subnet_terraform.id
        vpc_security_group_ids = [aws_security_group.sg_db_2.id]
        instance_type = "t2.micro"
        associate_public_ip_address = true
        tags = {
            Name = "ben_eng74_nodeapp_db"
        }
        key_name = var.ssh_key
}