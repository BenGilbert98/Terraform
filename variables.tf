variable "region" {
     default = "eu-west-1"
}

variable "instance" {
     default = "t2.micro"
}

variable "ami_app" {
     default = "ami-06ae4c93a11cb08d7"
}

variable "ami_db" {
     default = "ami-0a94b1fcfc91a9bc4"
}

variable "key_name" {
     default = "eng74.ben.aws.key.pem"
}
