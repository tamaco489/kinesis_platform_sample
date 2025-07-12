resource "aws_secretsmanager_secret" "shop_core_db" {
  name                    = local.shop_core_db_secret_id
  description             = "Shop core database secret"
  recovery_window_in_days = 0 # NOTE: In production, it is better to set a grace period before deletion

  tags = {
    Name        = "${var.env}-${var.db_types.shop.name}"
    Description = var.db_types.shop.description
  }
}

resource "aws_secretsmanager_secret_version" "shop_core_db" {
  secret_id     = aws_secretsmanager_secret.shop_core_db.id
  secret_string = jsonencode(data.sops_file.core_db_secret.data)
}
