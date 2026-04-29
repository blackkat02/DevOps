variable "ecr_name" {
  type        = string
  description = "Назва ECR репозиторію"
}

variable "scan_on_push" {
  type        = bool
  default     = true
  description = "Чи сканувати образи на вразливості при пуші"
}