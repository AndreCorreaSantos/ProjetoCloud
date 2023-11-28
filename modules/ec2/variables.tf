variable sg {
    description = "The ID of the security group"
    type        = string
}

variable public_subnet1_id {
    description = "The ID of the public subnet"
    type        = string
}

variable public_subnet2_id {
    description = "The ID of the public subnet"
    type        = string
}


variable ami {
    description = "The ami"
    type        = string
}

variable instance_type{
    description = "ID of instance type"
    type        = string
}

variable lb_target_group_arn{
    description = "ID of alb target group"
    type        = string
}

variable ec2_profile_name{
    description = "Name of the ec2 profile"
    type        = string
}

variable db_name{
    description = "Name of the database"
    type        = string
}

variable db_username{
    description = "Username of the database"
    type        = string
}

variable db_password{
    description = "Password of the database"
    type        = string
}


variable PATH_TO_YOUR_PUBLIC_KEY {
    description = "Path to your public key"
    type        = string
}

variable locust_sg_id {
    description = "ID of the locust security group"
    type        = string
}

variable dns_name{
    description = "DNS name of the load balancer"
    type        = string
}

variable aws_lb_id{
    description = "ID of the load balancer"
    type        = string
}