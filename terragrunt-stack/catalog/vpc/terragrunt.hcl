
terraform {
  source = "${get_repo_root()}/terraform/catalog/vpc"
}

inputs = {
  project_id = "teragrunt88"
  region     = "europe-west1"
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