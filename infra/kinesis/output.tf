output "shop_events_stream" {
  description = "kds (kinesis data stream) for shop events"
  value = {
    arn  = aws_kinesis_stream.shop_events.arn
    name = aws_kinesis_stream.shop_events.name
    id   = aws_kinesis_stream.shop_events.id
  }
}

output "firehose_delivery_stream" {
  description = "kinesis data firehose delivery stream for unified logs"
  value = {
    arn  = aws_kinesis_firehose_delivery_stream.unified_logs.arn
    name = aws_kinesis_firehose_delivery_stream.unified_logs.name
    id   = aws_kinesis_firehose_delivery_stream.unified_logs.id
  }
}
