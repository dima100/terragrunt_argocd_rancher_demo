variable "gke_endpoint" {
  type    = string
  default = "127.0.0.1"
}

variable "gke_ca_certificate" {
  type    = string
  default = ""
}

variable "cluster_endpoint" {
  type = string
}

variable "cluster_ca_certificate" {
  type    = string
  default = ""
}

variable "cluster_token" {
    type = string
    sensitive = true
}