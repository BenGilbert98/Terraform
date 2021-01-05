# Terraform
- Terraform is an IAC orchestration tool which allows you to create IAC for deployment on any cloud
- Terraform means "transform the Earth"
- It is a Hashicorp product

## Why Terraform
- It helps you scale up and down as per the user demand

### Best Use Cases
- It makes us cloud independent - works with AWS-Azure-GCP

**Other IAC tools**
- Orchestration with Terraform
- from an AMI to EC2 with customised configuration

### Language used is HCL is similar to JSON in terms of Syntax

## Setting up terraform

1) the provider is specified as "aws" with the region that the instance will be run in.
2) a resource is then declared to create an ec2 instance for our app. Within the resource the ami id, instance type, associate public ip address, name and key name specified
3) Similarly to step 2, a second resource is declared to create another ec2 instance for our db with the same variables specified.
4)```terraform plan``` is run in the terminal to verify that the main.tf file contains no errors
5) once verified, ```terraform apply``` is run in the terminal to create the ec2 instances.
 
```
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
```

## Using Variables
- In order to use variables we utilise another file called ```variables.tf```
- The code below shows the syntax for creating variables in a variables.tf file
- Inside the main.tf file these variables are called by writing ```var.<variable_name>```


```
variable "region" {
     default = "eu-west-1"
}

variable "instance" {
     default = "t2.micro"
}

variable "ami_app" {
     default = "<ami_app_id>"
}

variable "ami_db" {
     default = "<ami_db_id>"
}

variable "key_name" {
     default = "<aws_ssh_key>"
```
