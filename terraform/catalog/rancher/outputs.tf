output "api_url" {
  value       = "https://${var.rancher_hostname}"
  description = "The Rancher API endpoint URL"
}

output "token" {
  value       = rancher2_bootstrap.admin.token
  sensitive   = true
  description = "Rancher API token"
}