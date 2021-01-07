# APP module
# Create a public subnet
resource "aws_subnet" "subnet-public" {
  vpc_id     = var.vpc-terraform-name-id
  cidr_block = "108.21.1.0/24"
  # map_public_ip_on_launch = true

  tags = {
    Name = "${var.eng_class_person}subnet_public_terraform"
  }
}

# Create a SG
resource "aws_security_group" "sg_app" {
  name        = "public_sg_for_app_ben"
  description = "allows traffic to app"
  vpc_id      = var.vpc-terraform-name-id

  ingress {
    description = "HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "port 22 from my ip"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["90.218.243.127/32"]
  }

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Port 3000 for my ip"
    from_port   = 3000
    to_port     = 3000
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

# NCLS. --- Task 1
resource "aws_network_acl" "public_nacl" {
  vpc_id      = var.vpc-terraform-name-id
  subnet_ids = [aws_subnet.subnet-public.id]

  # OUT
  # port 80
  # port 443
  # Ephemeral ports 1024-65575
  egress {
    protocol   = "all"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "all"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
  # IN
  # Port 22
  # Port 80
  # Port 443
  # Ephemeral ports 1024-65575

  tags = {
    Name = "${var.eng_class_person}NACL_app_terraform"
  }
}


# ROUTES
resource "aws_route_table" "route_public_table"{
  vpc_id = var.vpc-terraform-name-id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.gw_id
  }

  tags = {
    Name = "${var.eng_class_person}route_table_terraform"
  }

}

resource "aws_route_table_association" "route_public_association"{
  route_table_id = aws_route_table.route_public_table.id
  subnet_id = aws_subnet.subnet-public.id
}

# move the app into the subnet ad try to get tge 502 error on port 80
#Instance EC2
resource "aws_instance" "nodejs_instance_ben" {
  ami = var.nodejs_app
  instance_type = "t2.micro"
  associate_public_ip_address = true

  # placing instance in correct subnet
  subnet_id = aws_subnet.subnet-public.id

  # Attaching correct SG
  security_groups = [aws_security_group.sg_app.id]

  tags = {
  Name = "ben_eng74_webapp_terraform"
  }
	key_name = var.ssh_key
        user_data = <<-EOF
                #!/bin/bash
                cd /home/ubuntu/app
                pm2 start app.js
                EOF
}