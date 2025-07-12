data "terraform_remote_state" "route53" {
  backend = "s3"
  config = {
    bucket = "${var.env}-kinesis-platform-sample-tfstate"
    key    = "route53/terraform.tfstate"
  }
}
