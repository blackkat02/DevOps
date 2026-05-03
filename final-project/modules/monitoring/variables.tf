variable "namespace" {
  description = "Namespace для розгортання стеку моніторингу"
  type        = string
  default     = "monitoring"
}

variable "grafana_admin_password" {
  description = "Пароль адміністратора для Grafana"
  type        = string
  sensitive   = true
}

variable "chart_version" {
  description = "Версія Helm-чарту kube-prometheus-stack"
  type        = string
  default     = "61.3.1"
}

variable "eks_security_group_id" {
  default = "" 
}