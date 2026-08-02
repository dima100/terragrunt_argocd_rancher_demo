include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "${get_repo_root()}/terraform/catalog/rancher"
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12.1"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.11.1"
    }
  }
}

data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://$${var.gke_endpoint}"
  cluster_ca_certificate = var.gke_ca_certificate != "" ? base64decode(var.gke_ca_certificate) : ""
  token                  = data.google_client_config.default.access_token
}

provider "helm" {
  kubernetes {
    host                   = "https://$${var.gke_endpoint}"
    cluster_ca_certificate = var.gke_ca_certificate != "" ? base64decode(var.gke_ca_certificate) : ""
    token                  = data.google_client_config.default.access_token
  }
}
EOF
}