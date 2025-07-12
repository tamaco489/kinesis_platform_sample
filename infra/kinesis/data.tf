data "aws_caller_identity" "current" {}

data "aws_kms_key" "kinesis" {
  key_id = "alias/aws/kinesis"
}

data "terraform_remote_state" "s3" {
  backend = "s3"
  config = {
    bucket = "${var.env}-kinesis-platform-sample-tfstate"
    key    = "s3/terraform.tfstate"
  }
}
