# Which Cloud Provider is required
# - AWS as we have our AMI's on AWS

provider "aws" {
        region = var.region 
}

resource "aws_instance" "nodejs_instance"{
        ami = var.ami_app
	instance_type = var.instance
	associate_public_ip_address = true
	tags = {
	    Name = "ben_eng74_nodeapp_version_2"
        }
	key_name = var.key_name
}

resource "aws_instance" "nodejs_db_instance"{
        ami = var.ami_db
        instance_type = var.instance
        associate_public_ip_address = true
        tags = {
            Name = "ben_eng74_nodeapp_db"
        }
        key_name = var.key_name
}

