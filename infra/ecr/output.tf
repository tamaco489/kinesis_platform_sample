output "shop_api" {
  description = "ecr repository for shop api"
  value = {
    arn  = aws_ecr_repository.shop_api.arn
    id   = aws_ecr_repository.shop_api.id
    name = aws_ecr_repository.shop_api.name
    url  = aws_ecr_repository.shop_api.repository_url
  }
}

output "shop_event_projector" {
  description = "ecr repository for shop event projector"
  value = {
    arn  = aws_ecr_repository.shop_event_projector.arn
    id   = aws_ecr_repository.shop_event_projector.id
    name = aws_ecr_repository.shop_event_projector.name
    url  = aws_ecr_repository.shop_event_projector.repository_url
  }
}
