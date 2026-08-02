data "rancher2_cluster" "workload_ca" {
  name = rancher2_cluster_v2.workload.name
}

output "endpoint" {
  # This dynamically builds the URL using the Rancher server URL passed from your hub cluster
  value = "${var.rancher_url}/k8s/clusters/${rancher2_cluster_v2.workload.cluster_v1_id}"
}


output "token" {
  value     = data.rancher2_cluster_v2.workload_status.kube_config
  sensitive = true
}

output "cluster_endpoint" {
  value = yamldecode(data.rancher2_cluster_v2.workload_status.kube_config)["clusters"][0]["cluster"]["server"]
  sensitive = true
}

output "ca_certificate" {
  value = data.rancher2_cluster.workload_ca.ca_cert
  sensitive = true
}

output "cluster_ca_certificate" {
  value     = data.rancher2_cluster.workload_ca.ca_cert
  sensitive = true
}