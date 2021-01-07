# Creating SG for APP instance
resource "aws_security_group" "sg_app" {
  name         = "eng74_ben_app_sg_terraform"
  description  = "Security group for app instance made with terraform"
  
  # allow ingress of port 22
  ingress {
    cidr_blocks = ["90.218.243.127/32"]  
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  } 

  # allow ingress of port 80  
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }

  # allow ingress of port 443
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
  }

  # allow ingress of port 27017
  ingress {
    cidr_blocks = ["52.16.77.47/32"]
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
  }


  # allow egress of all ports
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
# Creating SG for DB instance
resource "aws_security_group" "sg_db" {
  name         = "eng74_ben_db_sg_terraform"
  description  = "Security group for db instance made with terraform"

  # allow ingress of port 22
  ingress {
    cidr_blocks = ["90.218.243.127/32"]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }

  # allow ingress of port 80
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }

  # allow ingress of port 443
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
  }


  # allow egress of all ports
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
