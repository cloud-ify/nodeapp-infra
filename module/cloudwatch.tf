resource "aws_cloudwatch_log_group" "log-group" {
  name              = "/ecs/${var.service_name}-${var.environment}"
  kms_key_id        = var.cloudwatch_kms_key_id
  retention_in_days = var.log_retention_in_days

  tags = {
    Application = var.service_name
    Environment = var.environment
  }
}
