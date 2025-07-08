output "shop_event_projector" {
  description = "ecr repository for shop event projector"
  value = {
    arn  = aws_ecr_repository.shop_event_projector.arn
    id   = aws_ecr_repository.shop_event_projector.id
    name = aws_ecr_repository.shop_event_projector.name
    url  = aws_ecr_repository.shop_event_projector.repository_url
  }
}
