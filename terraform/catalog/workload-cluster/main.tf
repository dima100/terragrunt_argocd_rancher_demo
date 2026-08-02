# 1. Define the Cluster as a Custom Cluster (No machine pools or node drivers required)
resource "rancher2_cluster_v2" "workload" {
  name               = "workload-prod-cluster"
  kubernetes_version = "v1.28.3+k3s1"
}

# 2. Wait for the cluster to generate its kubeconfig
data "rancher2_cluster_v2" "workload_status" {
  name = rancher2_cluster_v2.workload.name
}

# 3. Create the cluster secret in the ArgoCD namespace on your Hub cluster
resource "kubernetes_secret_v1" "argocd_cluster_registration" {
  metadata {
    name      = "cluster-workload-prod"
    namespace = "argocd"
    labels = {
      "argocd.argoproj.io/secret-type" = "cluster"
    }
  }

  data = {
    name   = rancher2_cluster_v2.workload.name
    server = yamldecode(data.rancher2_cluster_v2.workload_status.kube_config)["clusters"][0]["cluster"]["server"]

    config = jsonencode({
      bearerToken = data.rancher2_cluster_v2.workload_status.kube_config
      tlsClientConfig = {
        insecure = true
      }
    })
  }
}