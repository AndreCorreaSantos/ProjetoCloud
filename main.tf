
provider "aws" {
region = "us-east-1"
}

module "vpc" {
  source = "./modules/vpc"
  region1 = "us-east-1a"
  region2 = "us-east-1b"
  subnet_cidr_block = "10.0.1.0/24"
}

module "rds" {
  source = "./modules/rds"
  subnet1_id = module.vpc.private_subnet1_id
  subnet2_id = module.vpc.private_subnet2_id
}

module "ec2" {
  source = "./modules/ec2"
  ami = "ami-0533f2ba8a1995cf9"
  instance_type = "t2.micro"
  web_sg_id = aws_security_group.web_sg.id
  private_subnet_id = module.vpc.private_subnet1_id
}

module "lb" {
  source = "./modules/lb"
  security_group_id = aws_security_group.web_sg.id
  public_subnet1_id = module.vpc.public_subnet1_id
  public_subnet2_id = module.vpc.public_subnet2_id
  vpc_id = module.vpc.vpc_id
  web_instance1_id = module.ec2.web_instance1_id
  web_instance2_id = module.ec2.web_instance2_id
}


resource "aws_security_group" "web_sg" {
  name   = "HTTP and SSH"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}