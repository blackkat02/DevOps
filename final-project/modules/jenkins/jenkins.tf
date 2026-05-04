resource "kubernetes_namespace_v1" "jenkins" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_service_account_v1" "jenkins" {
  depends_on = [kubernetes_namespace_v1.jenkins]
  metadata {
    name      = "jenkins"
    namespace = kubernetes_namespace_v1.jenkins.metadata[0].name

    annotations = {
      "eks.amazonaws.com/role-arn"     = var.irsa_role_arn
      "meta.helm.sh/release-name"      = "jenkins"
      "meta.helm.sh/release-namespace" = kubernetes_namespace_v1.jenkins.metadata[0].name
    }

    labels = {
      "app.kubernetes.io/managed-by" = "Helm"
    }
  }
}

resource "helm_release" "jenkins" {
  name       = "jenkins"
  repository = "https://charts.jenkins.io"
  chart      = "jenkins"
  namespace  = kubernetes_namespace_v1.jenkins.metadata[0].name
  version    = "5.8.12"

  values = [
    file("${path.module}/values.yaml"),
    yamlencode({
      controller = {
        serviceType = "ClusterIP" 
        
        admin = {
          password = var.admin_password
        }
        
        installPlugins = [
          "kubernetes:4306.vc91e951ea_eb_d",
          "workflow-aggregator",
          "git",
          "configuration-as-code:1963.v24e046127a_3f",
          "amazon-ecr"
        ]

        serviceAccount = {
          create = false
          name   = kubernetes_service_account_v1.jenkins.metadata[0].name
        }
      }
      persistence = {
        storageClass = "ebs-sc"
      }
    })
  ]

  wait    = false
  timeout = 600
}