# research how to create variables in terraform to use in main.tf
# use the variable instead of hard coding in main.tf

variable "region" {
default = "eu-west-1"
}

variable "nodejs_app" {
default = "ami-06ae4c93a11cb08d7"
}

#variable "db_ami" {
# default = "ami-05399c20723d2acbd"
#}

variable "ssh_key" {
default = "eng74.ben.aws.key"
}

variable "inst_type" {
default = "t2.micro"
}


variable "eng_class_person" {
  default = "eng74_ben_"
}
