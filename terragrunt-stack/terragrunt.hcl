# terragrunt-stack/terragrunt.hcl

remote_state {
  backend = "gcs"
  config = {
    project  = "teragrunt88"
    location = "europe-west1"
    bucket   = "teragrunt88-tfstate-bucket" # Must be globally unique in GCP
    prefix   = "${path_relative_to_include()}/terraform.tfstate"
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}