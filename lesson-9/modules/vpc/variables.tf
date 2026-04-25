variable "vpc_cidr_block" {
  type        = string
  description = "CIDR блок для VPC"
}

variable "vpc_name" {
  type        = string
  description = "Назва VPC"
}

variable "public_subnets" {
  type        = list(string)
  description = "Список CIDR для публічних підмереж"
}

variable "private_subnets" {
  type        = list(string)
  description = "Список CIDR для приватних підмереж"
}

variable "availability_zones" {
  type        = list(string)
  description = "Список зон доступності"
}