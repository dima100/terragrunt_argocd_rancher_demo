include "root" {
    path = find_in_parent_folders("root.hcl")
}

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  environment = local.env_vars.locals.environment
  raw_ca_cert = local.env_vars.locals.raw_ca_cert
  project_id  = local.env_vars.locals.project_id
  region      = local.env_vars.locals.region
  zone        = local.env_vars.locals.zone
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
  project      = local.project_id
  zone         = local.zone
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
