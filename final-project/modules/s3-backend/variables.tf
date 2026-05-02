variable "bucket_name" {
  description = "Назва S3 бакета (має бути унікальною globally)"
  type        = string
}

variable "table_name" {
  description = "Назва таблиці DynamoDB для блокування стейтів"
  type        = string
}