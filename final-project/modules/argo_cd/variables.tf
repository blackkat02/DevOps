variable "cluster_name" { type = string }

variable "git_repo_url" {
  description = "URL of the git repository containing Helm charts"
  type        = string
  default = "https://github.com/blackkat02/DevOps.git"
}