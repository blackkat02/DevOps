output "jenkins_url" {
  description = "The URL to access Jenkins"
  value       = "Wait for LoadBalancer DNS..."
}

output "jenkins_admin_password" {
  value     = "admin"
  sensitive = true
}