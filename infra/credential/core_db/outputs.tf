output "shop_core_db" {
  value = {
    name = aws_secretsmanager_secret.shop_core_db.name
    arn  = aws_secretsmanager_secret.shop_core_db.arn
  }
}
