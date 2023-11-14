output "vpc_id" {
    description = "The ID of the VPC"
    value       = aws_vpc.vpc1.id
}


output "public_subnet1_id" {
    description = "The ID of the public subnet1"
    value       = aws_subnet.public_subnet1.id

}

output "public_subnet2_id" {
    description = "The ID of the public subnet2"
    value       = aws_subnet.public_subnet2.id

}

output "private_subnet1_id" {
    description = "The ID of the private subnet1"
    value       = aws_subnet.private_subnet1.id
}

output "private_subnet2_id" {
    description = "The ID of the private subnet2"
    value       = aws_subnet.private_subnet2.id
}