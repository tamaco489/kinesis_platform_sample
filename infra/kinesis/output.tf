output "shop_events_stream" {
  description = "kds (kinesis data stream) for shop events"
  value = {
    arn  = aws_kinesis_stream.shop_events.arn
    name = aws_kinesis_stream.shop_events.name
    id   = aws_kinesis_stream.shop_events.id
  }
}
