# live/dev/europe-west1/terragrunt.stack.hcl

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  environment = local.env_vars.locals.environment
  raw_ca_cert = local.env_vars.locals.raw_ca_cert
  project_id  = local.env_vars.locals.project_id
  region      = local.env_vars.locals.region
  zone        = local.env_vars.locals.zone
}



unit "vpc" {
  source = "${get_repo_root()}/terragrunt-stack/catalog/vpc"
  path   = "vpc"

}

unit "gke" {
  source = "${get_repo_root()}/terragrunt-stack/catalog/gke-cluster"
  path   = "gke-cluster"
  dependencies = ["vpc"]
}


unit "argocd" {
  source       = "${get_repo_root()}/terragrunt-stack/catalog/argocd"
  path         = "argocd"
  dependencies = ["gke-cluster"]

  autoinclude {
    dependency "gke-cluster" {
      config_path = unit.gke.path

      mock_outputs = {
        endpoint       = "127.0.0.1"
        ca_certificate = base64encode(local.raw_ca_cert)
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

unit "rancher" {
  source       = "${get_repo_root()}/terragrunt-stack/catalog/rancher"
  path         = "rancher"
  dependencies = ["gke-cluster"]

  autoinclude {
    dependency "gke-cluster" {
      config_path = unit.gke.path

      mock_outputs = {
        endpoint       = "127.0.0.1"
        ca_certificate = base64encode(local.raw_ca_cert)
      }
      mock_outputs_allowed_terraform_commands = ["validate", "plan", "apply"]
      mock_outputs_merge_strategy_with_state  = "shallow"
    }

    inputs = {
      gke_endpoint       = dependency.gke-cluster.outputs.endpoint
      gke_ca_certificate = dependency.gke-cluster.outputs.ca_certificate
      rancher_admin_password = get_env("RANCHER_ADMIN_PASSWORD", "FO8l7mSr4p6wYV820Eqg")
    }
  }
}

unit "workload-cluster" {
  source = "${get_repo_root()}/terragrunt-stack/catalog/workload-cluster"
  path   = "workload-cluster"
  dependencies = ["rancher"]

    autoinclude {
        dependency "rancher" {
          config_path =  unit.rancher.path # Points to the generated rancher unit

          mock_outputs = {
            api_url = "https://127.0.0.1"
            token   = "mock-rancher-token"
          }
          mock_outputs_allowed_terraform_commands = ["validate", "plan", "apply"]
          mock_outputs_merge_strategy_with_state  = "shallow"
        }

        dependency "gke-cluster" {
              config_path = unit.gke.path
              mock_outputs = {
                endpoint       = "127.0.0.1"
                ca_certificate = base64encode(local.raw_ca_cert)
              }
              mock_outputs_allowed_terraform_commands = ["validate", "plan", "apply"]
              mock_outputs_merge_strategy_with_state  = "shallow"
            }

        inputs = {
          machine_config_id = "foo-bar-config"
          cluster_name      = "workload-prod-cluster"
          rancher_url   = dependency.rancher.outputs.api_url
          rancher_token = dependency.rancher.outputs.token
          gke_endpoint       = dependency.gke-cluster.outputs.endpoint
          gke_ca_certificate = dependency.gke-cluster.outputs.ca_certificate
        }
      }
}



unit "gitops-bridge" {
  source       = "${get_repo_root()}/terragrunt-stack/catalog/gitops-bridge"
  path         = "gitops-bridge"
  # Add workload_cluster to the dependencies list so Terragrunt builds it first
  dependencies = ["argocd", "rancher", "workload-cluster"]

  autoinclude {
    dependency "workload-cluster" {
      # Update this path to point to your new workload cluster unit's path
      config_path = unit.workload-cluster.path


      mock_outputs = {
        endpoint       = "https://127.0.0.1:6443"
        token          = "mock-token-for-plan"
        cluster_endpoint = "https://127.0.0.1:6443"
        ca_certificate = base64encode(local.raw_ca_cert)
        cluster_ca_certificate = base64encode(local.raw_ca_cert)
      }
      mock_outputs_allowed_terraform_commands = ["validate", "plan", "apply"]
      mock_outputs_merge_strategy_with_state  = "shallow"
    }

    inputs = {
      # Change from gke_* to generic cluster variables
      gke_endpoint           = dependency.workload-cluster.outputs.endpoint
      cluster_token          = dependency.workload-cluster.outputs.token
      cluster_endpoint       = dependency.workload-cluster.outputs.cluster_endpoint
//       ca_certificate         = dependency.workload-cluster.outputs.ca_certificate
//       cluster_ca_certificate = dependency.workload-cluster.outputs.cluster_ca_certificate
    }
  }
}
