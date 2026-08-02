resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  namespace        = "cert-manager"
  create_namespace = true
  version          = "v1.12.0"

  set {
    name  = "installCRDs"
    value = "true"
  }
}

resource "time_sleep" "wait_for_cert_manager" {
  depends_on      = [helm_release.cert_manager]
  create_duration = "45s"
}

resource "helm_release" "rancher" {
  depends_on = [time_sleep.wait_for_cert_manager]

  name             = "rancher"
  repository       = "https://releases.rancher.com/server-charts/stable"
  chart            = "rancher"
  namespace        = "cattle-system"
  create_namespace = true
  version          = "2.8.2"

  set {
    name  = "hostname"
    value = "rancher.local.test"
  }
  set {
    name  = "ingress.tls.source"
    value = "rancher"
  }
  set_sensitive {
    name  = "bootstrapPassword"
    value = "admin1234"
  }
  set {
    name  = "replicas"
    value = "1" # Save resources for local testing
  }
}