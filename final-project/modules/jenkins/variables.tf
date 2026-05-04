variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace for Jenkins"
  type        = string
  default     = "jenkins"
}

variable "jenkins_chart_version" {
  description = "Version of Jenkins Helm chart"
  type        = string
  default     = "5.8.12"
}

variable "admin_password" {
  description = "Admin password for Jenkins"
  type        = string
  sensitive   = true
}

variable "irsa_role_arn" {
  description = "ARN of the IRSA role for Jenkins to access ECR"
  type        = string
}
variable "ecr_repository_url" {
  description = "URL ECR репозиторію для Django app"
  type        = string
}
