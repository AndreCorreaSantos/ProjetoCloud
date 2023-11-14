resource "aws_lb" "web_lb" {
  name               = "web-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.security_group_id]
  subnets            = [var.public_subnet1_id,var.public_subnet2_id]  # Subnets where the ALB will be deployed
}

resource "aws_lb_target_group" "web_target_group" {
  name     = "web-target-group"
  port     = 80  # The port on which your EC2 instances are serving traffic
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path     = "/"
    protocol = "HTTP"
    port     = "80"
  }
}


resource "aws_lb_target_group_attachment" "web_target_attachment1" {
  target_group_arn = aws_lb_target_group.web_target_group.arn
  target_id        = var.web_instance1_id
}

resource "aws_lb_target_group_attachment" "web_target_attachment2" {
  target_group_arn = aws_lb_target_group.web_target_group.arn
  target_id        = var.web_instance2_id
}
