variable "env" {
  description = "The environment in which the acm will be created"
  type        = string
  default     = "stg"
}

variable "project" {
  description = "The project name"
  type        = string
  default     = "kinesis-platform-sample"
}

variable "service" {
  description = "The service name"
  type        = string
  default     = "shop-api"
}

locals {
  fqn = "${var.env}-${var.service}"
}
