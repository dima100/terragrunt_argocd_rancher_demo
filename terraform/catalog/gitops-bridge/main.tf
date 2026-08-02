
# The ArgoCD Application CRD
resource "kubernetes_manifest" "wordpress_argocd_app" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "wordpress"
      namespace = "argocd"
    }
    spec = {
      project = "default"
      source = {
        # This points to a public Git repo containing your WordPress Helm values or manifests.
        # You will need to create this repo!
        repoURL        = "https://github.com/dima100/wordpress-demo.git"
        targetRevision = "HEAD"
        path           = "."
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "wordpress"
      }
      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
        syncOptions = ["CreateNamespace=true"]
      }
    }
  }
}