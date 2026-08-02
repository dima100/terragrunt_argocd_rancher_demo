variable "machine_config_id" {
  type        = string
  description = "machine_config_id"
}

variable "rancher_url" {
  description = "The base URL of the Rancher server"
  type        = string
}

variable "rancher_token" {
  description = "The API token for the Rancher server"
  type        = string
  sensitive   = true
}

variable "gke_endpoint" {
  type    = string
  default = "127.0.0.1"
}

variable "gke_ca_certificate" {
  type    = string
  default = ""
}