output "alb_dns_name" {
  value = aws_lb.web_lb.dns_name
}

output "alb_target_group" {
  value = aws_lb_target_group.web_target_group.arn
  }

output "alb_id" {
  value = aws_lb.web_lb.id
}