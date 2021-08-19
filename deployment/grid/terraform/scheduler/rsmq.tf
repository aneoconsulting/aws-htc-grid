resource "kubernetes_deployment" "rsmq" {

  count =  var.grid_queue_service == "RSMQ" ? 1 : 0

  metadata {
    name      = "rsmq"
    labels = {
      app = "local-scheduler"
      service = "rsmq"
    }
  }
  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "local-scheduler"
        service = "rsmq"
      }
    }
    
    template {
      metadata {
        labels = {
          app = "local-scheduler"
          service = "rsmq"
        }
      }

      spec {
        container {
          image   = "redis"
          name    = "redis"
          command = ["redis-server"]

          port {
            container_port = 6379
          }

          volume_mount {
            name       = "rsmq-vol"
            mount_path = "/data"
          }
        }

        volume {
          name = "rsmq-vol"
        }
      }
    }
  }
}


resource "kubernetes_service" "rsmq" {

  count =  var.grid_queue_service == "RSMQ" ? 1 : 0

  metadata {
    name = "rsmq"
  }

  spec {
    selector = {
      app     = kubernetes_deployment.rsmq.metadata.0.labels.app
      service = kubernetes_deployment.rsmq.metadata.0.labels.service
    }
    type = "LoadBalancer"
    port {
      protocol = "TCP"
      port = var.rsmq_port
      target_port = 6379
      name = "rsmq"
    }
  }
}
