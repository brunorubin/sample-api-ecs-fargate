/* Application Load Balancer */
resource "aws_alb" "api_alb" {
  name               = "api-alb"
  subnets            = module.vpc.public_subnets
  security_groups    = ["${aws_security_group.alb_inbound_sg.id}"]
}

/* Target group for the ALB */
resource "aws_alb_target_group" "api_alb_target_group" {
  name        = "api-alb-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = "${module.vpc.vpc_id}"
  target_type = "ip"

  deregistration_delay = 10

  lifecycle {
    create_before_destroy = true
  }

  /* Health check configuration */
  health_check {
    port                = var.container_port
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 2
    interval            = 5
    path                = "/"
  }
}

/* ALB Listener */
resource "aws_alb_listener" "api_listener" {
  load_balancer_arn = "${aws_alb.api_alb.arn}"
  port              = "80"
  protocol          = "HTTP"
  depends_on        = [ aws_alb_target_group.api_alb_target_group ]

  default_action {
    target_group_arn = "${aws_alb_target_group.api_alb_target_group.arn}"
    type             = "forward"
  }
}

/* Output ALB endpoint */
output "alb_endpoint" {
  description = "The DNS name of the load balancer"
  value       = "http://${aws_alb.api_alb.dns_name}"
}