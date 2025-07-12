data "terraform_remote_state" "ecr" {
  backend = "s3"
  config = {
    bucket = "${var.env}-kinesis-platform-sample-tfstate"
    key    = "ecr/terraform.tfstate"
  }
}

data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "${var.env}-kinesis-platform-sample-tfstate"
    key    = "network/terraform.tfstate"
  }
}

data "terraform_remote_state" "kinesis" {
  backend = "s3"
  config = {
    bucket = "${var.env}-kinesis-platform-sample-tfstate"
    key    = "kinesis/terraform.tfstate"
  }
}

data "terraform_remote_state" "shop_core_db" {
  backend = "s3"
  config = {
    bucket = "${var.env}-kinesis-platform-sample-tfstate"
    key    = "credential/core_db/terraform.tfstate"
  }
}

# AWS managed key
data "aws_kms_key" "secretsmanager" {
  key_id = "alias/aws/secretsmanager"
}
