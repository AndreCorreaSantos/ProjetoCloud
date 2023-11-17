variable sg {
    description = "The ID of the security group"
    type        = string
}

variable private_subnet1_id {
    description = "The ID of the private subnet"
    type        = string
}

variable private_subnet2_id {
    description = "The ID of the private subnet"
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