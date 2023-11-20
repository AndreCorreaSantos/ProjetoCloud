
output "db_name" {
    value = aws_db_instance.rds.db_name
}

output "db_username" {
    value = aws_db_instance.rds.username
}

output "db_password" {
    value = aws_db_instance.rds.password 
}