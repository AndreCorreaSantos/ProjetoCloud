
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
  rds_sec_group = aws_security_group.rds_sec_group.id
}

module "ec2" {
  source = "./modules/ec2"
  ami = "ami-0fc5d935ebf8bc3bc"
  instance_type = "t2.micro"
  sg = aws_security_group.ec2_sec_group.id
  private_subnet1_id = module.vpc.public_subnet1_id #CHANGING TO PUBLIC TO DEBUC
  private_subnet2_id = module.vpc.public_subnet2_id
  lb_target_group_arn = module.lb.alb_target_group
  ec2_profile_name = module.iam.ec2_profile_name
  db_name = "mydb" 
  db_username = "admin"
  db_password = "password123"
  PATH_TO_YOUR_PUBLIC_KEY     = "/home/andre/.ssh/id_rsa.pub"
}

module "lb" {
  source = "./modules/lb"
  security_group_id = aws_security_group.lb_sec_group.id
  public_subnet1_id = module.vpc.public_subnet1_id
  public_subnet2_id = module.vpc.public_subnet2_id
  vpc_id = module.vpc.vpc_id
}

module "iam" {
  source = "./modules/iam"
}



resource "aws_security_group" "lb_sec_group" {
  name        = "alb-sg"
  description = "Security group for ALB"
  vpc_id      =  module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-sg"
  }
}

resource "aws_security_group" "ec2_sec_group" {
  name        = "ec2-sg"
  description = "Security group for my EC2 instances"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.lb_sec_group.id]
  }

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ec2-sg"
  }
}


resource "aws_security_group" "rds_sec_group" {
  name        = "rds-sg"
  description = "Security group for RDS instances"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sec_group.id]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-sg"
  }
}