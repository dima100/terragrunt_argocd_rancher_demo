# live/dev/europe-west1/terragrunt.stack.hcl

unit "vpc" {
  source = "${get_repo_root()}/terragrunt-stack/catalog/vpc"
  path   = "vpc"
}

unit "gke" {
  source = "${get_repo_root()}/terragrunt-stack/catalog/gke-cluster"
  path   = "gke-cluster"
  dependencies = ["vpc"]
  inputs = {
    project      = "teragrunt88"
    zone         = "europe-west1-b"
    network_name = unit.vpc.outputs.network_name
    subnet_name  = unit.vpc.outputs.subnet_name
  }
}

unit "argocd" {
  source       = "${get_repo_root()}/terragrunt-stack/catalog/argocd"
  path         = "argocd"
  dependencies = ["gke"]
  inputs = {
    gke_endpoint = unit.gke.outputs.endpoint
    gke_ca_certificate  = unit.gke.outputs.ca_certificate
  }
}

unit "rancher" {
  source       = "${get_repo_root()}/terragrunt-stack/catalog/rancher"
  path         = "rancher"
  dependencies = ["gke"]
  inputs = {
    gke_endpoint = unit.gke.outputs.endpoint
    gke_ca_certificate  = unit.gke.outputs.ca_certificate
  }
}

// unit "gitops-bridge" {
//   source       = "${get_repo_root()}/terragrunt-stack/catalog/gitops-bridge"
//   path         = "gitops-bridge"
//   dependencies = ["argocd", "rancher"]
//   inputs = {
//     gke_endpoint = unit.gke.outputs.endpoint
//     gke_ca_cert  = unit.gke.outputs.ca_certificate
//   }
// }
