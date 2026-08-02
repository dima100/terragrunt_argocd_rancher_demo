variable "gke_endpoint" {
  type    = string
  default = "127.0.0.1"
}

variable "gke_ca_certificate" {
  type    = string
  default = ""
}

variable "rancher_admin_password" {
  type        = string
  description = "Initial admin password for the Rancher bootstrap process"
  sensitive   = true
  default = "FO8l7mSr4p6wYV820Eqg"
}

variable "rancher_hostname" {
  type = string
  default = "rancher.local.test"
}