resource "kubernetes_namespace" "jenkins" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "jenkins" {
  name       = "jenkins"
  repository = "https://charts.jenkins.io"
  chart      = "jenkins"
  namespace  = kubernetes_namespace.jenkins.metadata[0].name
  version    = "5.8.12"

  values = [
    file("${path.module}/values.yaml"),
    yamlencode({
      controller = {
        admin_password = var.admin_password
        
        installPlugins = [
          "kubernetes:latest",
          "workflow-aggregator:latest",
          "git:latest",
          "configuration-as-code:latest",
          "amazon-ecr:latest"
        ]
        fsGroup   = 1000
        runAsUser = 1000
      }
      persistence = {
        storageClass = "ebs-sc"
      }
    })
  ]

  timeout = 1200
  wait    = true
}