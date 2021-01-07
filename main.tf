# Which Cloud Provider is required
# - AWS as we have our AMI's on AWS

provider "aws" {
        region = var.region 
}

# Create VPC
resource "aws_vpc" "eng74_ben_terraform_vpc" {
  cidr_block       = "108.21.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "${var.eng_class_person}vpc_terraform"
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
    Name = "${var.eng_class_person}igw_terraform"
  }
}

# resource "aws_route_table_association" "route_public_association" {
#   subnet_id      = aws_subnet.eng74_ben_public_subnet_terraform.id
#   route_table_id = aws_route_table.eng74_ben_route_public_terraform.id
# }


# call the app module
module "app" {
  source = "./modules/app_tier"
  vpc_id = aws_vpc.eng74_ben_terraform_vpc.id
  eng_class_person = var.eng_class_person
  gw_id = aws_internet_gateway.eng74_ben_igw_terraform.id
  nodejs_app = var.ami_app
  ssh_key = var.key_name
  db_ip = module.db.db_private_ip
}

# call the db module
module "db" {
  source = "./modules/db_tier"
  vpc_id_db = aws_vpc.eng74_ben_terraform_vpc.id
  eng_class_person = var.eng_class_person
  nodejs_db = var.ami_db
  app_sg_id = module.app.sg_app_id
  ssh_key = var.key_name
}