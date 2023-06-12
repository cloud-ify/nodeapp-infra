resource "aws_ecr_repository" "app_repo" {
  name                 = "${var.app_name}-${local.environment}"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
  tags = {
    Environment = local.environment
    Terraform   = true
    CreatedBy   = "Ifeoma"
  }
}

resource "aws_ecr_lifecycle_policy" "repo_policy" {
  repository = "${var.app_name}-${local.environment}"
  policy     = <<EOF
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Keep last 10 images",
      "selection": {
        "tagStatus": "any",
        "countType": "imageCountMoreThan",
        "countNumber": 10
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
EOF
  depends_on = [aws_ecr_repository.app_repo]
}
