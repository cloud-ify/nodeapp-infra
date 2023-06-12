variable "service_name" {
  type = string
}
variable "environment" {}
variable "launch_type" {
  type = string
  default = "FARGATE"
}
variable "task_role_arn" {}
variable "container_definitions" {}
variable "vpc_id" {}
variable "cloudwatch_kms_key_id" {
  description = ""
  type = string
  default = null
}
variable "log_retention_in_days" {
  type    = number
  default = 1
}

variable "task_definition" {
  description = "This will pass in the parameters to the task definition for proper Fargate sizing see [here](https://aws.amazon.com/fargate/pricing/)"
  type        = object({
    cpu_limit    = number,
    memory_limit = number,
  })
  default = {
    cpu_limit    = 512,
    memory_limit = 1024
  }
}

variable "service_config" {
  description = "Required configuration parameters for the ECS service"
  type = object({
    task_memory = string
    task_cpu    = string
    cluster_arn = string,
    desired_count = number,
    network_config = object({
      subnets = list(string),
      security_groups = list(string)
    }),
    lb_config = object({
      container_config = object({
        container_name = string,
        container_port = number
      }),
      target_group_config = object({
        port = number,
        protocol = string,
        vpc_id = string
      }),
      target_group_health_check = object({
        interval = number,
        timeout = number,
        healthy_threshold = number,
        unhealthy_threshold = number,
        protocol = string,
        port = string,
        path = string,
        deregistration_delay = number
      }),
      lb_listener_config = object({
        lb_arn = string,
        port = number,
        protocol = string,
        ssl_policy = optional(string),
        certificate_arn = optional(string)
      })
    }),
  })
}

variable "tags" {
  type = map(string)
  default = null
}
