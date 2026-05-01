variable "bucket_name" {
  description = "Назва S3 бакета"
  type        = string
  default     = "borys-bucket-terraform"
}

variable "table_name" {
  description = "Назва таблиці DynamoDB"
  type        = string
  default     = "terraform-locks"
}

variable "admin_password" {
  description = "Jenkins admin password"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Password for the RDS database"
  type        = string
  sensitive   = true
}

variable "use_aurora" {
  description = "If true, use Aurora Cluster instead of standard RDS instance"
  type        = bool
  default     = false
}
