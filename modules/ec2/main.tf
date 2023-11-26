resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = file("/home/andre/.ssh/id_rsa.pub")
}


# launch_template.tf
resource "aws_launch_template" "launch_template" {
  name = "MyLaunchTemplate"

  image_id               = var.ami
  instance_type          = var.instance_type
  vpc_security_group_ids = [var.sg]
  user_data = base64encode(templatefile("${path.module}/user_data.tftpl", { db_name = var.db_name, 
                                                                            db_username = var.db_username, 
                                                                            db_password = var.db_password}))

  iam_instance_profile {
    name = var.ec2_profile_name
  }

}


resource "aws_cloudwatch_log_group" "my_log_group" {
  name = "/my-fastapi-app/logs"
}

# auto_scaling_group.tf
resource "aws_autoscaling_group" "autoscaling_group" {
  name                 = "MyAutoScalingGroup"
  desired_capacity     = 2
  max_size             = 5
  min_size             = 1
  launch_template {
    id = aws_launch_template.launch_template.id
    version = "$Latest"
  }
  vpc_zone_identifier  = [var.public_subnet1_id, var.public_subnet2_id]
  target_group_arns = [var.lb_target_group_arn]
}

# scaling_policy.tf
resource "aws_autoscaling_policy" "scale_up" {
  name                   = "ScaleUp"
  scaling_adjustment    = 1
  adjustment_type       = "ChangeInCapacity"
  cooldown              = 10
  autoscaling_group_name = aws_autoscaling_group.autoscaling_group.name
}

# cloudwatch_alarm.tf
resource "aws_cloudwatch_metric_alarm" "cpu_alarm" {
  alarm_name          = "HighCPU"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "10"
  statistic           = "Average"
  threshold           = "20"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.autoscaling_group.name
  }

  alarm_actions = [aws_autoscaling_policy.scale_up.arn] # SCALE UP
}

# cloudwatch_low_cpu_alarm.tf
resource "aws_cloudwatch_metric_alarm" "low_cpu_alarm" {
  alarm_name          = "LowCPU"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "10"
  statistic           = "Average"
  threshold           = "10"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.autoscaling_group.name
  }

  alarm_actions = [aws_autoscaling_policy.scale_down.arn]  # CRIAR ISSO!
}

# scaling_policy_scale_down.tf
resource "aws_autoscaling_policy" "scale_down" {
  name                   = "ScaleDown"
  scaling_adjustment    = -1  # Negative value for scale down
  adjustment_type       = "ChangeInCapacity"
  cooldown              = 10
  autoscaling_group_name = aws_autoscaling_group.autoscaling_group.name
}



# alb_integration.tf
resource "aws_autoscaling_attachment" "auto_attachment" {
  autoscaling_group_name = aws_autoscaling_group.autoscaling_group.name
  lb_target_group_arn   = var.lb_target_group_arn
}

resource "aws_autoscaling_policy" "scale_up_down_tracking" {
  policy_type            = "TargetTrackingScaling"
  name                   = "scale-up-down-tracking"
  estimated_instance_warmup = 180
  autoscaling_group_name = aws_autoscaling_group.autoscaling_group.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"
      resource_label = "${split("/", var.aws_lb_id)[1]}/${split("/", var.aws_lb_id)[2]}/${split("/", var.aws_lb_id)[3]}/targetgroup/${split("/", var.lb_target_group_arn)[1]}/${split("/", var.lb_target_group_arn)[2]}"
    }
    target_value = 200
  }

  lifecycle {
    create_before_destroy = true 
  }
}


#### LOCUST

resource "aws_instance" "locust" {
    ami                         = "ami-0fc5d935ebf8bc3bc"
    instance_type               = "t2.micro"
    vpc_security_group_ids      = [var.locust_sg_id]
    subnet_id                   = var.public_subnet1_id
    associate_public_ip_address = true
    
    user_data = base64encode(templatefile("${path.module}/user_data_locust.tftpl", {
        dns_name = var.dns_name
    }))

    tags = {
        Name = "ec2-locust"
    }
    
}