output "vpc_id" {
    description = "The ID of the VPC"
    value       = aws_vpc.vpc1.id
}


output "public_subnet_id" {
    description = "The ID of the public subnet"
    value       = aws_subnet.public_subnet.id
}