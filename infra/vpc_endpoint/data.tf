data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "${var.env}-kinesis-platform-sample-tfstate"
    key    = "network/terraform.tfstate"
  }
}
