resource "aws_kinesis_stream" "shop_events" {
  name = local.fqn

  # NOTE: When stream_mode = "ON_DEMAND", shard_count does not need to be set
  # shard_count = 1

  # the duration (in hours) that data records added to the stream are retained
  # minimum: 24h, maximum: 8769h (365 days)
  retention_period = 24

  # specify whether to forcefully delete all registered consumers (backend applications) when deleting the stream.
  # false: Do not delete, true: Delete
  enforce_consumer_deletion = false

  # stream level metrics
  # DOC: https://docs.aws.amazon.com/streams/latest/dev/monitoring-with-cloudwatch.html
  shard_level_metrics = [
    "IncomingBytes",
    "OutgoingBytes",
  ]

  # specify the capacity mode for the data stream
  # on-demand: pay-per-request, provisioned: fixed capacity
  # DOC: https://docs.aws.amazon.com/streams/latest/dev/how-do-i-size-a-stream.html
  stream_mode_details {
    stream_mode = "ON_DEMAND"
  }

  encryption_type = "KMS"
  kms_key_id      = data.aws_kms_key.kinesis.arn

  tags = { Name = local.fqn }
}
