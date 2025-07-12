variable "env" {
  description = "The environment in which the core db secret manager will be created"
  type        = string
  default     = "stg"
}

variable "project" {
  description = "The project name"
  type        = string
  default     = "kinesis-platform-sample"
}

variable "db_types" {
  description = "DB types configuration with name and description for each type"
  type = object({
    shop = object({
      name        = string
      description = string
    })
  })
  default = {
    shop = {
      name        = "shop"
      description = "shop database"
    }
  }
}

locals {
  fqn                    = "${var.env}-${var.project}"
  shop_core_db_secret_id = "${var.project}/${var.env}/${var.db_types.shop.name}/core/rds-cluster"
}
