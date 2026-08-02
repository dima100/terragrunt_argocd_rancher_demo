terraform {
  required_providers {
    rancher2 = {
      source  = "rancher/rancher2"
      version = "~> 3.0"
    }
  }
}


resource "rancher2_cluster" "downstream" {
  name        = "my-rancher-managed-cluster"
  description = "Cluster created and managed via Rancher"

  gke_config_v2 {
    project_id     = "teragrunt88"
    region         = "europe-west1"
    cluster_name   = "rancher-downstream-spot"

    # Configure your node pools, VPC networks, etc. here
  }
}


resource "rancher2_cluster" "custom_cluster" {
  name        = "rancher-hybrid-cluster"
  description = "Cluster with dedicated manager and worker nodes"
  rke2_config {
    version = "v1.28.5+rke2r1"
  }
}

# Create a registration token to get the join commands
resource "rancher2_cluster_registration_token" "token" {
  cluster_id = rancher2_cluster.custom_cluster.id
}