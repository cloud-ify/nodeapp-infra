locals {
  environment = var.environment

  tags = merge(
    var.tags,
    {
      Environment = local.environment
    }
  )
}
