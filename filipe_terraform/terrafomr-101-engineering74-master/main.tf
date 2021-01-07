# module myip {
#  source  = "4ops/myip/http"
#  version = "1.0.0"
# }

provider "aws" {

 region = "eu-west-1"
#access_key = "must not write the key here"
#secert_key = "must not write the key here"
}


# Create a VPC
resource "aws_vpc" "vpc-terraform-name" {
  cidr_block       = "108.21.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "${var.eng_class_person}vpc_terraform"
  }
}

# IGW
resource "aws_internet_gateway" "gw" {
  #reference vpc_id dynamically by:
  # calling the resource,
  # followed by the name of the resource
  # followed by the parameter you want
  vpc_id = aws_vpc.vpc-terraform-name.id

  tags = {
    Name = "${var.eng_class_person}igw_terraform"
  }
}

# call the app module
module "app" {
  source = "./modules/app_tier"
  vpc-terraform-name-id = aws_vpc.vpc-terraform-name.id
  eng_class_person = var.eng_class_person
  gw_id = aws_internet_gateway.gw.id
  nodejs_app = var.nodejs_app
  ssh_key = var.ssh_key
}

# Using the sg_app.id to make a DB SG

resource "aws_security_group" "sg_db" {
  name = "private_sg_for_db_ben"
  description = "allows traffic to db from app"
  vpc_id = aws_vpc.vpc-terraform-name.id

  ingress {
    description = "Allows 27017 from app"
    from_port   = 27017
    to_port     = 27017
    protocol         = "tcp"
    security_groups = [module.app.sg_app_id] # How to get an output from a module
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


















# Monitor
# Decide trigger
# ask it to scale out
# replicate ec2 withing public subnet
# Load balancer to distribute traffic to new ec2
# We will use built in tools from AWS
