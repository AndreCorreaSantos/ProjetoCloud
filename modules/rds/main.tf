resource "aws_db_instance" "rds" {
  identifier            = "my-rds-instance"
  allocated_storage     = 20  # Set the allocated storage size in GB
  storage_type          = "gp2"  # Set storage type to gp2 (SSD) or standard (magnetic)
  engine                = "mysql"  # Specify the database engine
  engine_version        = "8.0"     # Specify the database engine version
  instance_class        = "db.t2.micro"  # Set the instance type
  parameter_group_name = "default.mysql8.0"
  db_name = "mydb"  # Set the database name
  username              = "admin"       # Set the master username
  password              = "password123" # Set the master password

  # Other optional settings
  multi_az              = false  # Set to true for multi-AZ deployment TEMPORARILY REMOVING IT TO TEST
  publicly_accessible   = false  # Set to true if the RDS should be publicly accessible

  # Configure the database subnet group and parameter group if needed
  db_subnet_group_name  = aws_db_subnet_group.db_subnet_group.name
  skip_final_snapshot   = true 

  vpc_security_group_ids = [var.rds_sec_group]
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "my-db-subnet-group"
  subnet_ids = [var.subnet1_id, var.subnet2_id]  # Specify your subnet IDs
  tags = {
    Name = "my-db-subnet-group"
  }
}


