resource "kubernetes_config_map" "lambda_local" {
  metadata {
    name = "lambda-local"
  }

  data = {
    TASKS_STATUS_TABLE_NAME=aws_dynamodb_table.htc_tasks_status_table.name,
    TASKS_QUEUE_NAME=var.sqs_queue,
    TASKS_QUEUE_DLQ_NAME=var.sqs_dlq,
    METRICS_ARE_ENABLED=var.metrics_are_enabled,
    ERROR_LOG_GROUP=var.error_log_group,
    ERROR_LOGGING_STREAM=var.error_logging_stream,
    TASK_INPUT_PASSED_VIA_EXTERNAL_STORAGE = var.task_input_passed_via_external_storage,
    GRID_STORAGE_SERVICE = var.grid_storage_service,
    S3_BUCKET = aws_s3_bucket.htc-stdout-bucket.id,
    REDIS_URL = "redis",
    METRICS_GRAFANA_PRIVATE_IP = var.nlb_influxdb,
    REGION = var.region,
    AWS_DEFAULT_REGION = var.region,
    SQS_PORT = var.local_services_port,
    DYNAMODB_PORT = var.dynamodb_port,
    USERNAME = var.access_key,
    PASSWORD = var.secret_key,
    AWS_ACCESS_KEY_ID = var.access_key,
    AWS_SECRET_ACCESS_KEY = var.secret_key,
    AWS_LAMBDA_FUNCTION_TIMEOUT = var.lambda_timeout,
    RSMQ_PORT = var.rsmq_port,
    SQS_ENDPOINT = "rsmq"
  }
}

resource "kubernetes_service" "cancel_tasks" {
  metadata {
    name = "cancel-tasks"
  }

  spec {
    selector = {
      app     = kubernetes_deployment.cancel_tasks.metadata.0.labels.app
      service =  kubernetes_deployment.cancel_tasks.metadata.0.labels.service
    }
    type = "LoadBalancer"
    port {
      protocol = "TCP"
      port = var.cancel_tasks_port
      target_port = 8080
      name = "cancel-tasks"
    }
  }
}

resource "kubernetes_deployment" "cancel_tasks" {
  metadata {
    name      = "cancel-tasks"
    labels = {
      app = "local-scheduler"
      service = "cancel-tasks"
    }
  }
  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "local-scheduler"
        service = "cancel-tasks"
      }
    }
    
    template {
      metadata {
        labels = {
          app = "local-scheduler"
          service = "cancel-tasks"
        }
      }

      spec {
        container {
          image   = var.cancel_tasks_image
          name    = "cancel-tasks"

          resources {
            limits = {
              memory = "1024Mi"
            }
          }

          env_from {
            config_map_ref {
              name = kubernetes_config_map.lambda_local.metadata.0.name
              optional = false
            }
          }

          env {
            name = "METRICS_CANCEL_TASKS_LAMBDA_CONNECTION_STRING"
            value =var.metrics_cancel_tasks_lambda_connection_string
          }

          port {
            container_port = 8080
          }
        }
      }
    }
  }
  depends_on = [
    kubernetes_service.local_services,
  ]
}

resource "kubernetes_service" "get_results" {
  metadata {
    name = "get-results"
  }

  spec {
    selector = {
      app     = kubernetes_deployment.get_results.metadata.0.labels.app
      service =  kubernetes_deployment.get_results.metadata.0.labels.service
    }
    type = "LoadBalancer"
    port {
      protocol = "TCP"
      port = var.get_results_port
      target_port = 8080
      name = "get-results"
    }
  }
}

resource "kubernetes_deployment" "get_results" {
  metadata {
    name      = "get-results"
    labels = {
      app = "local-scheduler"
      service = "get-results"
    }
  }
  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "local-scheduler"
        service = "get-results"
      }
    }
    
    template {
      metadata {
        labels = {
          app = "local-scheduler"
          service = "get-results"
        }
      }

      spec {
        container {
          image   = var.get_results_image
          name    = "get-results"

          resources {
            limits = {
              memory = "1024Mi"
            }
          }

          env_from {
            config_map_ref {
              name = kubernetes_config_map.lambda_local.metadata.0.name
              optional = false
            }
          }

          env {
            name = "METRICS_GET_RESULTS_LAMBDA_CONNECTION_STRING"
            value =var.metrics_get_results_lambda_connection_string
          }

          port {
            container_port = 8080
          }
        }
      }
    }
  }
  depends_on = [
    kubernetes_service.local_services,
  ]
}

resource "kubernetes_service" "submit_task" {
  metadata {
    name = "submit-task"
  }

  spec {
    selector = {
      app     = kubernetes_deployment.submit_task.metadata.0.labels.app
      service =  kubernetes_deployment.submit_task.metadata.0.labels.service
    }
    type = "LoadBalancer"
    port {
      protocol = "TCP"
      port = var.submit_task_port
      target_port = 8080
      name = "submit-task"
    }
  }
}

resource "kubernetes_deployment" "submit_task" {
  metadata {
    name      = "submit-task"
    labels = {
      app = "local-scheduler"
      service = "submit-task"
    }
  }
  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "local-scheduler"
        service = "submit-task"
      }
    }
    
    template {
      metadata {
        labels = {
          app = "local-scheduler"
          service = "submit-task"
        }
      }

      spec {
        container {
          image   = var.submit_task_image
          name    = "submit-task"

          resources {
            limits = {
              memory = "1024Mi"
            }
          }

          env_from {
            config_map_ref {
              name = kubernetes_config_map.lambda_local.metadata.0.name
              optional = false
            }
          }

          env {
            name = "METRICS_SUBMIT_TASKS_LAMBDA_CONNECTION_STRING"
            value =var.metrics_submit_tasks_lambda_connection_string
          }

          port {
            container_port = 8080
          }
        }
      }
    }
  }
  depends_on = [
    kubernetes_service.local_services,
  ]
}

resource "kubernetes_service" "ttl_checker" {
  metadata {
    name = "ttl-checker"
  }

  spec {
    selector = {
      app     = kubernetes_deployment.ttl_checker.metadata.0.labels.app
      service =  kubernetes_deployment.ttl_checker.metadata.0.labels.service
    }
    type = "LoadBalancer"
    port {
      protocol = "TCP"
      port = var.ttl_checker_port
      target_port = 8080
      name = "ttl-checker"
    }
  }
}

resource "kubernetes_deployment" "ttl_checker" {
  metadata {
    name      = "ttl-checker"
    labels = {
      app = "local-scheduler"
      service = "ttl-checker"
    }
  }
  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "local-scheduler"
        service = "ttl-checker"
      }
    }
    
    template {
      metadata {
        labels = {
          app = "local-scheduler"
          service = "ttl-checker"
        }
      }

      spec {
        container {
          image   = var.ttl_checker_image
          name    = "ttl-checker"

          resources {
            limits = {
              memory = "1024Mi"
            }
          }

          env_from {
            config_map_ref {
              name = kubernetes_config_map.lambda_local.metadata.0.name
              optional = false
            }
          }

          env {
            name = "METRICS_TTL_CHECKER_LAMBDA_CONNECTION_STRING"
            value =var.metrics_ttl_checker_lambda_connection_string
          }

          port {
            container_port = 8080          
          }
        }
      }
    }
  }
  depends_on = [
    kubernetes_service.local_services,
  ]
}

resource "kubernetes_cron_job" "ttl_checker" {
  depends_on = [
    kubernetes_deployment.ttl_checker,
  ]
  metadata {
    name = "ttl-checker"
  }
  spec {
    concurrency_policy            = "Replace"
    failed_jobs_history_limit     = 5
    schedule                      = "* * * * *"
    starting_deadline_seconds     = 10
    successful_jobs_history_limit = 10
    job_template {
      metadata {}
      spec {
        backoff_limit              = 2
        ttl_seconds_after_finished = 10
        template {
          metadata {}
          spec {
            container {
              name    = "curl"
              image   = "curlimages/curl:latest"
              args = ["-XPOST", "http://ingress-nginx-controller.ingress-nginx:80/check", "-d", "{}"]
            }
          }
        }
      }
    }
  }
}