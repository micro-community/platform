# Based off https://github.com/nats-io/k8s/blob/53bfb34f36bfcd08a9434c558b6b77fa9081118a/nats-server/simple-nats.yml

resource "kubernetes_config_map" "nats_server" {
  metadata {
    namespace = var.resource_namespace
    name      = "nats-config"
  }
  data = {
    "nats.conf" = <<-NATSCONF
      pid_file: "/var/run/nats/nats.pid"
      http: 8222

      cluster {
        port: 6222
        routes [
          nats://nats-0.nats.${var.resource_namespace}.svc:6222
          nats://nats-1.nats.${var.resource_namespace}.svc:6222
          nats://nats-2.nats.${var.resource_namespace}.svc:6222
        ]

        cluster_advertise: $CLUSTER_ADVERTISE
        connect_retries: 30
      }
    NATSCONF
  }
}

locals {
  nats_ports = {
    "client"    = 4222,
    "cluster"   = 6222,
    "monitor"   = 8222,
    "metrics"   = 7777,
    "leafnodes" = 7422,
    "gateways"  = 7522,
  }
}

resource "kubernetes_service" "nats" {
  metadata {
    namespace = var.resource_namespace
    name      = "nats"
    labels = {
      "app" = "nats"
    }
  }
  spec {
    selector = {
      "app" = "nats"
    }
    cluster_ip = "None"
    dynamic "port" {
      for_each = local.nats_ports
      content {
        name = port.key
        port = port.value
      }
    }
  }
}

resource "kubernetes_service" "nats_cluster" {
  metadata {
    namespace = var.resource_namespace
    name      = "nats-cluster"
    labels = {
      "app" = "nats"
    }
  }
  spec {
    selector = {
      "app" = "nats"
    }
    port {
      name        = "client"
      port        = lookup(local.nats_ports, "client", 4222)
      target_port = "client"
    }
  }
}

resource "kubernetes_stateful_set" "nats" {
  metadata {
    namespace = var.resource_namespace
    name      = "nats"
    labels = {
      "app" = "nats"
    }
  }
  spec {
    replicas     = 3
    service_name = "nats"
    selector {
      match_labels = {
        "app" = "nats"
      }
    }
    template {
      metadata {
        labels = {
          "app" = "nats"
        }
      }
      spec {
        volume {
          name = "config-volume"
          config_map {
            default_mode = "0644"
            name         = kubernetes_config_map.nats_server.metadata.0.name
          }
        }
        volume {
          name = "pid"
          empty_dir {}
        }
        share_process_namespace          = true
        termination_grace_period_seconds = 60
        container {
          name  = "nats"
          image = var.nats_image
          dynamic "port" {
            for_each = local.nats_ports
            content {
              name           = port.key
              container_port = port.value
            }
          }
          command = [
            "nats-server",
            "--config",
            "/etc/nats-config/nats.conf"
          ]
          env {
            name = "POD_NAME"
            value_from {
              field_ref {
                field_path = "metadata.name"
              }
            }
          }
          env {
            name = "POD_NAMESPACE"
            value_from {
              field_ref {
                field_path = "metadata.namespace"
              }
            }
          }
          env {
            name  = "CLUSTER_ADVERTISE"
            value = "$(POD_NAME).nats.$(POD_NAMESPACE).svc"
          }
          volume_mount {
            name       = "config-volume"
            mount_path = "/etc/nats-config"
          }
          volume_mount {
            name       = "pid"
            mount_path = "/var/run/nats"
          }
          liveness_probe {
            http_get {
              path = "/"
              port = lookup(local.nats_ports, "monitor", 8222)
            }
            initial_delay_seconds = 10
            timeout_seconds       = 5
          }
          readiness_probe {
            http_get {
              path = "/"
              port = lookup(local.nats_ports, "monitor", 8222)
            }
            initial_delay_seconds = 10
            timeout_seconds       = 5
          }
          lifecycle {
            pre_stop {
              exec {
                command = [
                  "/bin/sh", "-c", "/nats-server -sl=ldm=/var/run/nats/nats.pid && /bin/sleep 60"
                ]
              }
            }
          }
        }
      }
    }
    update_strategy {
      type = "RollingUpdate"
    }
  }
  depends_on = [kubernetes_config_map.nats_server]
}

resource "kubernetes_pod_disruption_budget" "nats" {
  metadata {
    name      = "nats"
    namespace = var.resource_namespace
  }
  spec {
    max_unavailable = "1"
    selector {
      match_labels = {
        "app" = "nats"
      }
    }
  }
}
