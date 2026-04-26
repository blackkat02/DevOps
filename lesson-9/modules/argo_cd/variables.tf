variable "cluster_name" { type = string }

variable "git_repo_url" {
  description = "URL of the git repository containing Helm charts"
  type        = string
  default     = "https://github.com/YOUR_USERNAME/YOUR_REPO.git" # Зміни на свій!
}