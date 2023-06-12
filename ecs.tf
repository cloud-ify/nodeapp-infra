resource "aws_lb" "application_load_balancer" {
  name               = "${var.app_name}-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = aws_subnet.public.*.id
  security_groups = [
    aws_security_group.lb_sg_web.id,
  ]

  tags = merge(
    local.tags,
    {
      Name = "${var.app_name}-alb"
    }
  )
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.application_load_balancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_ecs_cluster" "cluster" {
  name = var.cluster_name

  tags = merge(
    local.tags,
    {
      Name = var.cluster_name
    }
  )
}

##################################### NODEJS TEMPLATE #####################################
data "template_file" "nodejs_template" {
  template = file("./container-definitions/nodejs-template.json")
  vars = {
    environment  = local.environment
    account_id   = "631837846915"
    service_name = var.app_name
    service_port = "8000"
    aws_region   = "us-east-1"
    image_tag    = "dummy-tag"
    bucket_name  = "ify-demo"
    env_file     = "node.env"
  }
}

module "nodejs-template" {
  source                = "./module"
  service_name          = var.app_name
  task_role_arn         = aws_iam_role.ecsTaskExecutionRole.arn
  environment           = local.environment
  container_definitions = data.template_file.nodejs_template.rendered
  vpc_id                = aws_vpc.vpc.id

  service_config = {
    task_cpu      = "512"
    task_memory   = "1024"
    cluster_arn   = aws_ecs_cluster.cluster.arn
    desired_count = 1

    network_config = {
      subnets = aws_subnet.private.*.id
      security_groups = [
        # aws_security_group.service_security_group.id,
        aws_security_group.lb_sg_web.id,
      ]
    }
    lb_config = {
      container_config = {
        container_name = var.app_name
        container_port = 8000
      }
      target_group_config = {
        port     = 8000
        protocol = "HTTP"
        vpc_id   = aws_vpc.vpc.id
      }
      target_group_health_check = {
        interval             = 120
        timeout              = 5
        healthy_threshold    = 3
        unhealthy_threshold  = 3
        protocol             = "HTTP"
        port                 = "8000"
        path                 = "/"
        deregistration_delay = 60
      }
      lb_listener_config = {
        lb_arn          = aws_lb.application_load_balancer.arn
        port            = 8000
        protocol        = "HTTP"
        ssl_policy      = null
        certificate_arn = null
      }
    }
  }

  depends_on = [
    aws_vpc.vpc,
    aws_ecr_repository.app_repo
  ]

  tags = merge(
    var.tags,
    {
      Name = var.app_name
    }
  )
}
