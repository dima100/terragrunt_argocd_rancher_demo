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
  dependencies = ["gke-cluster"]

  autoinclude {
    dependency "gke-cluster" {
      config_path = "../gke-cluster"

      mock_outputs = {
        endpoint       = "127.0.0.1"
        ca_certificate = "bW9jay1jYS1jZXJ0"
      }
      mock_outputs_allowed_terraform_commands = ["validate", "plan"]
      mock_outputs_merge_strategy_with_state  = "shallow"
    }

    inputs = {
      gke_endpoint       = dependency.gke-cluster.outputs.endpoint
      gke_ca_certificate = dependency.gke-cluster.outputs.ca_certificate
    }
  } # <--- Notice autoinclude closes HERE, after the inputs!
}

unit "rancher" {
  source       = "${get_repo_root()}/terragrunt-stack/catalog/rancher"
  path         = "rancher"
  dependencies = ["gke-cluster"]

  autoinclude {
    dependency "gke-cluster" {
      config_path = "../gke-cluster"

      mock_outputs = {
        endpoint       = "127.0.0.1"
        ca_certificate = "bW9jay1jYS1jZXJ0"
      }
      mock_outputs_allowed_terraform_commands = ["validate", "plan"]
      mock_outputs_merge_strategy_with_state  = "shallow"
    }

    inputs = {
      gke_endpoint       = dependency.gke-cluster.outputs.endpoint
      gke_ca_certificate = dependency.gke-cluster.outputs.ca_certificate
    }
  }
}


unit "gitops-bridge" {
  source       = "${get_repo_root()}/terragrunt-stack/catalog/gitops-bridge"
  path         = "gitops-bridge"
  dependencies = ["argocd", "rancher"]
  autoinclude {
    dependency "gke-cluster" {
      config_path = "../gke-cluster"

      mock_outputs = {
        endpoint       = "127.0.0.1"
        ca_certificate = "bW9jay1jYS1jZXJ0"
      }
      mock_outputs_allowed_terraform_commands = ["validate", "plan"]
      mock_outputs_merge_strategy_with_state  = "shallow"
    }

    inputs = {
      gke_endpoint       = dependency.gke-cluster.outputs.endpoint
      gke_ca_certificate = dependency.gke-cluster.outputs.ca_certificate
    }
  }
}
