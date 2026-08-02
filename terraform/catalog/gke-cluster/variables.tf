variable "zone" {
  type        = string
  description = "GCP зона для размещения GKE кластера и Spot-нод (например, europe-west1-b)"
}

variable "network_name" {
  type        = string
  description = "Имя VPC сети (передается из модуля VPC)"
}

variable "subnet_name" {
  type        = string
  description = "Имя подсети (передается из модуля VPC)"
}