variable "bucket_name" { type = string }
variable "table_name" { type = string }
variable "cluster_name" { type = string }

variable "admin_password" {
  type      = string
  sensitive = true
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "grafana_admin_password" {
  type      = string
  sensitive = true
}

variable "eks_security_group_id" {
  description = "Security Group ID of the EKS cluster to allow access to RDS"
  type        = string
}

variable "use_aurora" { type = bool }
variable "db_name"    { type = string }
variable "db_user"    { type = string }
variable "engine"     { type = string }
variable "engine_version" { type = string }
variable "instance_class" { type = string }
variable "db_family"  { type = string }
variable "db_port"    { type = number }