# =================================================================
# general
# =================================================================
variable "env" {
  description = "The environment in which the shop event projector will be created"
  type        = string
  default     = "stg"
}

variable "project" {
  description = "The project name"
  type        = string
  default     = "kinesis-platform-sample"
}

variable "region" {
  description = "The region in which the shop event projector will be created"
  type        = string
  default     = "ap-northeast-1"
}

variable "product" {
  description = "The product name"
  type        = string
  default     = "shop-event-projector"
}

locals {
  fqn = "${var.env}-${var.product}"
}
