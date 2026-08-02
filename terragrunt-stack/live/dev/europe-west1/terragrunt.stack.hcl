# live/dev/europe-west1/terragrunt.stack.hcl

locals {
  raw_ca_cert = <<EOF
-----BEGIN CERTIFICATE-----
MIIE1DCCA7ygAwIBAgIICxbgS8VtPC4wDQYJKoZIhvcNAQELBQAwWTEgMB4GA1UE
AwwXUGxheXRlY2ggRGV2ZWxvcG1lbnQgQ0ExETAPBgNVBAsMCFNlY3VyaXR5MRUw
EwYDVQQKDAxQbGF5dGVjaCBQTEMxCzAJBgNVBAYTAklNMB4XDTI2MDUwNDAwMDAw
MFoXDTI4MDUwNDEyMDAwMFowgYMxGzAZBgNVBAMMEm1vbi13cy5tb25kZXYucHRl
YzEZMBcGA1UECgwQUGxheXRlY2ggRXN0b25pYTEZMBcGA1UECwwQSW5mcmEgT3Bl
cmF0aW9uczELMAkGA1UEBhMCRUUxETAPBgNVBAgMCFRhcnR1bWFhMQ4wDAYDVQQH
DAVUYXJ0dTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAMOqA5opj+nz
gJwfIWVBgU6FRTCmKJNGvaIJh9PX38wguN6wcgWg0QpTqK9fXxJM5wQZZNtdbyg7
5BnbEP/dUcUUnNbvHxFKfJZYh/du/p+XEaBoOjspEERiofxGAhCy/56BXSFAbRSK
HFX9L730jGCK66KlQJe1MyKE+x1Icm/9LWbDBifoWswAIbFko5jhxutxasUhJ2hR
q0CqtICnIENMW7DUyMzUFf3gszSyso0+nNGxcm4a0r8CYlD3QumxbykHMoVXtgBw
Qtgoaeyf0r1dKzjc80Gd0aJqN+cHOXsrDE+65c5nI6yH3A9BXB5kubImJzFYkfTd
Cqyqh5CxjlMCAwEAAaOCAXMwggFvMA4GA1UdDwEB/wQEAwIFoDATBgNVHSUEDDAK
BggrBgEFBQcDATAdBgNVHQ4EFgQUp9/t76Nn4p25U29US8U6d3Xwo7owTgYDVR0R
AQH/BEQwQoISbW9uLXdzLm1vbmRldi5wdGVjghVtb24td3MtMDEubW9uZGV2LnB0
ZWOCFW1vbi13cy0wMi5tb25kZXYucHRlYzAMBgNVHRMBAf8EAjAAMB8GA1UdIwQY
MBaAFPUplQXJ+1DSfRfB4whIzvwpt7YaMIGpBgNVHR8EgaEwgZ4wgZugOqA4hjZo
dHRwOi8vY2EucGxheXRlY2hnYW1pbmcuY29tL1BsYXl0ZWNoRGV2ZWxvcG1lbnRD
QS5jcmyiXaRbMFkxIDAeBgNVBAMMF1BsYXl0ZWNoIERldmVsb3BtZW50IENBMREw
DwYDVQQLDAhTZWN1cml0eTEVMBMGA1UECgwMUGxheXRlY2ggUExDMQswCQYDVQQG
EwJJTTANBgkqhkiG9w0BAQsFAAOCAQEAqHyMCpjjA/3v4f6yrUrgdqJkgwK0TO42
sUWlJ0B+pGR2I3HttwDL9E/0NblTKuA/cL+XBk2sN5LuJM1YpbfI32ptWwf3K8Tn
Nv/JV559gQMJC9U1LwNsEkEIwLFEHcVH813heTZM9d79RLy2RJo9OF1wsNBehCzt
jtq29qvNa1Zyn2h9hsPl13UujCvYpwe/Xpr86ky3eXAwLa30Qr93+BuipEyMJZkI
t9nZ8Uzw4tYw25TSSsGWbjuvIHR2xA5Qm4XAjbnsyhRV1kUeqtIyE6qPOZaLP42v
6C+785pHJsm5BJ6h2uR/Ii+9mnWwLC2VVcldBwqqQGGtzCIbQM68VA==
-----END CERTIFICATE-----

EOF


}

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
      ca_certificate         = dependency.workload-cluster.outputs.ca_certificate
      cluster_ca_certificate = dependency.workload-cluster.outputs.cluster_ca_certificate
    }
  }
}
