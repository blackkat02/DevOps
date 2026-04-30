output "db_host" {
  description = "The connection endpoint for the database"
  value       = var.use_aurora ? try(aws_rds_cluster.this[0].endpoint, "") : try(aws_db_instance.this[0].address, "")
}

# Порт
output "db_port" {
  description = "The port the database is listening on"
  value       = var.use_aurora ? try(aws_rds_cluster.this[0].port, 5432) : try(aws_db_instance.this[0].port, 5432)
}

# Ім'я БД
output "db_name" {
  description = "The name of the database"
  value       = var.db_name
}

# СЕКРЕТ 
output "db_password" {
  description = "The master password for the database"
  value       = var.db_password
  sensitive   = true # Terraform приховає це в консолі
}

# Security Group ID
output "db_security_group_id" {
  value = aws_security_group.rds.id
}
