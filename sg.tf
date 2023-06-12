# resource "aws_security_group" "service_security_group" {
#   name   = "${var.app_name}-service-sg"
#   vpc_id = aws_vpc.vpc.id

#   ingress {
#     from_port = 0
#     to_port   = 0
#     protocol  = "All"
#     security_groups = [
#       aws_security_group.lb_sg_web.id,
#       aws_security_group.lb_sg_api.id,
#     ]
#   }

#   egress {
#     from_port        = 0
#     to_port          = 0
#     protocol         = "-1"
#     cidr_blocks      = ["0.0.0.0/0"]
#     ipv6_cidr_blocks = ["::/0"]
#   }

#   tags = merge(
#     local.tags,
#     {
#       Name = "${var.app_name}-service-sg"
#     }
#   )
# }

resource "aws_security_group" "lb_sg_web" {
  name   = "${var.app_name}-web-${local.environment}-sg"
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.tags,
    {
      Name = "${var.app_name}-web-${local.environment}-sg"
    }
  )
}
