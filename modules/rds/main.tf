provider "aws" {
  region = "us-east-1"  # Set your desired AWS region
}

resource "aws_db_instance" "example" {
  identifier            = "my-rds-instance"
  allocated_storage     = 20  # Set the allocated storage size in GB
  engine                = "mysql"  # Specify the database engine
  engine_version        = "5.7"     # Specify the database engine version
  instance_class        = "db.t2.micro"  # Set the instance type
  db_name = "mydb"  # Set the database name
  username              = "admin"       # Set the master username
  password              = "password123" # Set the master password

  # Other optional settings
  multi_az              = false  # Set to true for multi-AZ deployment
  publicly_accessible   = false  # Set to true if the RDS should be publicly accessible

  # Configure the database subnet group and parameter group if needed
  db_subnet_group_name  = aws_db_subnet_group.db_subnet_group.name
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "my-db-subnet-group"
  subnet_ids = [var.subnet1_id, var.subnet2_id]  # Specify your subnet IDs
}


