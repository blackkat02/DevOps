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