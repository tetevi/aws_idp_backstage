resource "aws_eip" "nlb" {
  domain = "vpc"
}

resource "aws_lb" "backstage" {
  name               = "backstage-demo-nlb"
  internal           = false
  load_balancer_type = "network"

  subnet_mapping {
    subnet_id     = data.aws_subnets.default.ids[0]
    allocation_id = aws_eip.nlb.id
  }
}

resource "aws_lb_target_group" "backstage" {
  name        = "backstage-demo-tg"
  port        = var.backstage_port
  protocol    = "TCP"
  vpc_id      = data.aws_vpc.default.id
  target_type = "ip"

  health_check {
    protocol            = "TCP"
    port                = var.backstage_port
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 30
  }

  deregistration_delay = 30
}

resource "aws_lb_listener" "backstage" {
  load_balancer_arn = aws_lb.backstage.arn
  port              = var.backstage_port
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backstage.arn
  }
}

output "nlb_static_ip" {
  description = "Permanent Elastic IP fronting Backstage. Register the GitHub callback against this and it never changes across task recreates."
  value       = aws_eip.nlb.public_ip
}

output "backstage_url" {
  value = "http://${aws_eip.nlb.public_ip}:${var.backstage_port}"
}

output "github_oauth_callback" {
  value = "http://${aws_eip.nlb.public_ip}:${var.backstage_port}/api/auth/github/handler/frame"
}