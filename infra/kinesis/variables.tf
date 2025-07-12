variable "env" {
  description = "The environment in which the shop event projector kds (kinesis data stream) will be created"
  type        = string
  default     = "stg"
}

variable "project" {
  description = "The project name"
  type        = string
  default     = "kinesis-platform-sample"
}

variable "region" {
  description = "The region in which the shop event projector kds (kinesis data stream) will be created"
  type        = string
  default     = "ap-northeast-1"
}

variable "event_types" {
  description = "Event types configuration with name and description for each type"
  type = object({
    shop = object({
      name        = string
      description = string
    })
    # user_activity = object({
    #   name        = string
    #   description = string
    # })
    # system_audit = object({
    #   name        = string
    #   description = string
    # })
  })
  default = {
    shop = {
      name        = "shop-event-projector"
      description = "shop event projector events"
    }
    # user_activity = {
    #   name        = "user-activity"
    #   description = "user activity events"
    # }
    # system_audit = {
    #   name        = "system-audit"
    #   description = "system audit events"
    # }
  }
}

locals {
  fqn = "${var.env}-${var.project}"
}
