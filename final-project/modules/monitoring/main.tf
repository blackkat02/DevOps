resource "kubernetes_namespace_v1" "monitoring" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "prometheus_stack" {
  name       = "prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = kubernetes_namespace_v1.monitoring.metadata[0].name
  version    = var.chart_version
  
  timeout         = 900
  cleanup_on_fail = true
  wait            = true

  values = [
    yamlencode({
      alertmanager     = { enabled = false }
      nodeExporter     = { enabled = false }
      kubeStateMetrics = { enabled = false }

      grafana = {
        enabled       = true
        adminPassword = var.grafana_admin_password
        service       = { type = "ClusterIP" }
      }

      prometheus = {
        prometheus = {
        prometheusSpec = {
          serviceMonitorSelectorNilUsesHelmValues = false

          resources = {
            requests = { 
              cpu    = "200m" 
              memory = "512Mi" 
            }
            limits   = { 
              cpu    = "500m" 
              memory = "1Gi" 
            }
          }

          storageSpec = {
            emptyDir = { medium = "Memory" }
          }
        }
      }
      }
    })
  ]
}