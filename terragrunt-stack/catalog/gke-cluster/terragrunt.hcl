include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "${get_repo_root()}/terraform/catalog/gke-cluster"
}

dependency "vpc" {
  config_path = "../vpc"

  # Mocks allow 'terragrunt plan' or 'validate' to run before VPC is created
  mock_outputs = {
    network_name = "mock-network"
    subnet_name  = "mock-subnet"
  }

}

inputs = {
  project      = "teragrunt88"
  zone         = "europe-west1-b"
  network_name = dependency.vpc.outputs.network_name
  subnet_name  = dependency.vpc.outputs.subnet_name
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "google" {
  project = "teragrunt88"
  region  = "europe-west1"
}
EOF
}
