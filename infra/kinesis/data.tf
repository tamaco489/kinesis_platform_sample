data "aws_kms_key" "kinesis" {
  key_id = "alias/aws/kinesis"
}
