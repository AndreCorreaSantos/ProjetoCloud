resource "aws_lb" "web_lb" {
  name               = "web-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.security_group_id] #CHECAR AQUI
  subnets            = [var.public_subnet1_id,var.public_subnet2_id]  # Subnets where the ALB will be deployed
  enable_deletion_protection = false
  enable_cross_zone_load_balancing = true
  tags = {
    Name = "web-lb"
  }
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
    enabled = true
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 10
    interval = 30
  }
}

resource "aws_lb_listener" "lb_listener"{
  load_balancer_arn = aws_lb.web_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.web_target_group.arn
    type             = "forward"
  }
}

