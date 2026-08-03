include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  # Adjust the relative path depending on how deep your environment folder is nested.
  # This path must point directly to your catalog module.
  source = "${get_repo_root()}/terraform/catalog/workload-cluster"
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF

terraform {
  required_providers {
    rancher2 = {
      source  = "rancher/rancher2"
      version = ">= 8.0.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "rancher2" {
  api_url   = "https://localhost:8443"
  token_key = var.rancher_token
  insecure  = true
}

data "google_client_config" "default" {}

provider "kubernetes" {
  host = "https://$${var.gke_endpoint}"
  cluster_ca_certificate = base64decode("$${var.gke_ca_certificate}")
  token = data.google_client_config.default.access_token
}
EOF
}

inputs = {
  machine_config_id = "foo-bar-config"
}