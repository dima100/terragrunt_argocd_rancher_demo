terraform {
  source = "${get_repo_root()}/terraform/catalog/gitops-bridge"
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF


data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://$${var.gke_endpoint}"
  cluster_ca_certificate = var.gke_ca_certificate != "" ? base64decode(var.gke_ca_certificate) : ""
  token                  = data.google_client_config.default.access_token
}

EOF
}