variable "app_name" {
  default = "nodejs-template"
}

variable "cluster_name" {
  default = "ecs-cluster"
}

variable "tags" {
  type = map(string)
  default = {
    Terraform = true
    CreatedBy = "Ifeoma"
  }
}

variable "public_subnets" {
  type    = list(string)
  default = ["10.10.100.0/24", "10.10.101.0/24"]
}

variable "private_subnets" {
  type    = list(string)
  default = ["10.10.0.0/24", "10.10.1.0/24"]
}

variable "availability_zones" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b"]
}

variable "private_propagating_vgws" {
  type        = list(string)
  default     = []
  description = "List of virtual gateways for route propagation on the private subnets"
}

variable "environment" {
  type = string
  default = "dev"
}
