variable "db_name" { type = string }
variable "vpc_id" { type = string }
variable "private_subnet_ids" { type = list(string) }
variable "eks_security_group_id" { type = string }

variable "use_aurora" {
  description = "If true, create Aurora Cluster. If false, create standard RDS instance."
  type        = bool
  default     = false
}

variable "db_port" {
  type    = number
  default = 5432
}

variable "db_family" {
  type    = string
  default = "postgres15"
}

variable "engine" { type = string }
variable "engine_version" { type = string }
variable "instance_class" { type = string }
variable "db_user" { type = string }
variable "db_password" { 
  type      = string 
  sensitive = true 
}