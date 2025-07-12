variable "env" {
  description = "The environment in which the s3 will be created"
  type        = string
  default     = "stg"
}

variable "project" {
  description = "The project name"
  type        = string
  default     = "kinesis-platform-sample"
}

locals {
  fqn = "${var.env}-${var.project}"
}
