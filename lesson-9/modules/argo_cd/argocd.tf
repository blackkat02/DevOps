resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = kubernetes_namespace.argocd.metadata[0].name
  version    = "7.3.4"

  values = [
    file("${path.module}/values.yaml")
  ]
}

resource "helm_release" "argocd_apps" {
  name       = "argocd-apps"
  chart      = "${path.module}/charts"
  namespace  = kubernetes_namespace.argocd.metadata[0].name

  depends_on = [helm_release.argocd]
}