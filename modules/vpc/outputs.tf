output "vpc_id" {
    description = "The ID of the VPC"
    value       = aws_vpc.vpc1.id
}


output "public_subnet_id" {
    description = "The ID of the public subnet"
    value       = aws_subnet.public_subnet.id

}

output "private_subnet1_id" {
    description = "The ID of the private subnet1"
    value       = aws_subnet.private_subnet1.id
}

output "private_subnet2_id" {
    description = "The ID of the private subnet2"
    value       = aws_subnet.private_subnet2.id
}