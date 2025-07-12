# =================================================================
# general
# =================================================================
variable "env" {
  description = "The environment in which the shop api will be created"
  type        = string
  default     = "stg"
}

variable "project" {
  description = "The project name"
  type        = string
  default     = "kinesis-platform-sample"
}

variable "region" {
  description = "The region in which the shop api will be created"
  type        = string
  default     = "ap-northeast-1"
}

variable "service" {
  description = "The service name"
  type        = string
  default     = "shop-api"
}

locals {
  fqn = "${var.env}-${var.service}"
}
