provider "aws" {
  default_tags {
    tags = {
      Project = var.project
      Env     = var.env
      Managed = "terraform"
    }
  }
}

terraform {
  required_version = "~> 1.12.0"
  backend "s3" {
    bucket = "stg-kinesis-platform-sample-tfstate"
    key    = "kinesis/terraform.tfstate"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}
