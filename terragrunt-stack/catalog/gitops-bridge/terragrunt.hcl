include "root" {
    path = find_in_parent_folders("root.hcl")
}


terraform {
  source = "${get_repo_root()}/terraform/catalog/gitops-bridge"
}


generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF

data "google_client_config" "default" {}

provider "kubernetes" {
  host = "localhost:8443"
  cluster_ca_certificate = base64decode("$${var.gke_ca_certificate}")
  insecure = true
  token = data.google_client_config.default.access_token
}

provider "helm" {
  kubernetes {
    host                   = "localhost:8443"
    cluster_ca_certificate = var.gke_ca_certificate != "" ? base64decode(var.gke_ca_certificate) : ""
    token                  = data.google_client_config.default.access_token
  }
}
EOF
}


// generate "provider" {
//   path      = "provider.tf"
//   if_exists = "overwrite"
//   contents  = <<EOF
//
// data "google_client_config" "default" {}
//
// provider "kubernetes" {
//   host = "$${var.gke_endpoint}"
//   cluster_ca_certificate = base64decode("$${var.gke_ca_certificate}")
//   token = data.google_client_config.default.access_token
// }
//
// provider "helm" {
//   kubernetes {
//     host                   = "$${var.gke_endpoint}"
//     cluster_ca_certificate = var.gke_ca_certificate != "" ? base64decode(var.gke_ca_certificate) : ""
//     token                  = data.google_client_config.default.access_token
//   }
// }
// EOF
// }