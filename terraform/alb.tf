resource "aws_alb" "btk" {
  name               = "${var.app}-alb"
  internal           = false
  load_balancer_type = "application"
  idle_timeout       = 5
  subnets            = aws_subnet.btk-public.*.id
  security_groups    = [aws_security_group.external.id]

  tags = {
    Name        = "${var.app}-alb"
    Environment = var.environment
  }
}

resource "aws_lb_target_group" "btk" {
  name     = "${var.app}-tg"
  port     = 443
  protocol = "HTTP"
  vpc_id   = aws_vpc.btk.id

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    port                = 5000
    matcher             = "200"
    timeout             = "3"
    path                = "/healthz"
    unhealthy_threshold = "2"
  }

  tags = {
    Name        = "${var.app}-lb-tg"
    Environment = var.environment
  }
}

resource "aws_lb_listener" "listenters" {
  load_balancer_arn = aws_alb.btk.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.btk.arn
  }
}
