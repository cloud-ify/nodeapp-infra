resource "aws_ecs_service" "aws-ecs-service" {
  name                 = "${var.service_name}"
  cluster              = var.service_config["cluster_arn"]
  launch_type          = var.launch_type
  task_definition      = "${aws_ecs_task_definition.aws-ecs-task.family}:${max(aws_ecs_task_definition.aws-ecs-task.revision, data.aws_ecs_task_definition.main.revision)}"
  desired_count        = var.service_config["desired_count"]
  force_new_deployment = true

  network_configuration {
    assign_public_ip = false
    subnets          = var.service_config["network_config"]["subnets"]
    security_groups = var.service_config["network_config"]["security_groups"]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group.arn
    container_name = var.service_config["lb_config"]["container_config"]["container_name"]
    container_port = var.service_config["lb_config"]["container_config"]["container_port"]
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = false
  }

  depends_on = [aws_lb_listener.listener]

  tags = var.tags

  lifecycle {
    ignore_changes = [
      task_definition
    ]
  }
}

resource "aws_ecs_task_definition" "aws-ecs-task" {
  family = "${var.service_name}-${var.environment}"

  container_definitions = var.container_definitions

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = var.service_config["task_memory"]
  cpu                      = var.service_config["task_cpu"]
  task_role_arn            = var.task_role_arn
  execution_role_arn       = var.task_role_arn

  tags = var.tags
}

data "aws_ecs_task_definition" "main" {
  task_definition = aws_ecs_task_definition.aws-ecs-task.family
}
