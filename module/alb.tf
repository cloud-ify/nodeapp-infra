resource "aws_lb_listener" "listener" {
  load_balancer_arn = var.service_config["lb_config"]["lb_listener_config"]["lb_arn"]
  port = var.service_config["lb_config"]["lb_listener_config"]["port"]
  protocol = var.service_config["lb_config"]["lb_listener_config"]["protocol"]
  ssl_policy = var.service_config["lb_config"]["lb_listener_config"]["ssl_policy"]
  certificate_arn = var.service_config["lb_config"]["lb_listener_config"]["certificate_arn"]

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}

resource "aws_lb_target_group" "target_group" {
  name = var.service_name
  port = var.service_config["lb_config"]["target_group_config"]["port"]
  protocol = var.service_config["lb_config"]["target_group_config"]["protocol"]
  vpc_id = var.service_config["lb_config"]["target_group_config"]["vpc_id"]
  target_type = "ip"
  deregistration_delay = var.service_config["lb_config"]["target_group_health_check"]["deregistration_delay"]
  tags = var.tags

  health_check {
    enabled = true
    interval = var.service_config["lb_config"]["target_group_health_check"]["interval"]
    timeout = var.service_config["lb_config"]["target_group_health_check"]["timeout"]
    healthy_threshold = var.service_config["lb_config"]["target_group_health_check"]["healthy_threshold"]
    unhealthy_threshold = var.service_config["lb_config"]["target_group_health_check"]["unhealthy_threshold"]
    protocol = var.service_config["lb_config"]["target_group_health_check"]["protocol"]
    port = "traffic-port"
    path = var.service_config["lb_config"]["target_group_health_check"]["path"]
  }

  lifecycle {
    create_before_destroy = true
  }
}
