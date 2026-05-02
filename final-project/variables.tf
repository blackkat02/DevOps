variable "bucket_name" {
  description = "Назва S3 бакета для стейту"
  type        = string
}

variable "table_name" {
  description = "Назва DynamoDB таблиці для локування стейту"
  type        = string
}

variable "admin_password" {
  description = "Пароль адміністратора Jenkins"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Пароль до бази даних"
  type        = string
  sensitive   = true
}

variable "use_aurora" {
  description = "Перемикач Aurora/RDS"
  type        = bool
}

# Решта змінних, які ти використовуєш у tfvars:
variable "db_name" { type = string }
variable "db_user" { type = string }
variable "engine" { type = string }
variable "engine_version" { type = string }
variable "instance_class" { type = string }
variable "db_family" { type = string }
variable "db_port" { type = number }
variable "cluster_name" { type = string }