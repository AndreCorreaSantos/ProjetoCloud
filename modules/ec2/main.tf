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

# auto_scaling_group.tf
resource "aws_autoscaling_group" "autoscaling_group" {
  desired_capacity     = 2
  max_size             = 5
  min_size             = 1
  launch_template {
    id = aws_launch_template.launch_template.id
    version = "$Latest"
  }
  vpc_zone_identifier  = [var.private_subnet1_id, var.private_subnet2_id]
  target_group_arns = [var.lb_target_group_arn]
}

# scaling_policy.tf
resource "aws_autoscaling_policy" "scale_up" {
  name                   = "ScaleUp"
  scaling_adjustment    = 1
  adjustment_type       = "ChangeInCapacity"
  cooldown              = 300
  autoscaling_group_name = aws_autoscaling_group.autoscaling_group.name
}

# cloudwatch_alarm.tf
resource "aws_cloudwatch_metric_alarm" "cpu_alarm" {
  alarm_name          = "CPUAlarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 70

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.autoscaling_group.name
  }

  alarm_actions = ["arn:aws:sns:us-east-1:123456789012:MyTopic"] # criar depois
}

# cloudwatch_low_cpu_alarm.tf
resource "aws_cloudwatch_metric_alarm" "low_cpu_alarm" {
  alarm_name          = "LowCPUAlarm"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 30  # Adjust this threshold based on your requirements

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.autoscaling_group.name
  }

  alarm_actions = ["arn:aws:sns:us-east-1:123456789012:MyScaleDownTopic"]  # CRIAR ISSO!
}

# scaling_policy_scale_down.tf
resource "aws_autoscaling_policy" "scale_down" {
  name                   = "ScaleDown"
  scaling_adjustment    = -1  # Negative value for scale down
  adjustment_type       = "ChangeInCapacity"
  cooldown              = 300
  autoscaling_group_name = aws_autoscaling_group.autoscaling_group.name
}



# alb_integration.tf
resource "aws_autoscaling_attachment" "auto_attachment" {
  autoscaling_group_name = aws_autoscaling_group.autoscaling_group.name
  lb_target_group_arn   = var.lb_target_group_arn
}
