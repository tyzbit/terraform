resource "kubernetes_deployment" "atlantis" {

  metadata {
    name      = "atlantis"
    namespace = "atlantis"
  }
  spec {
    selector {
      match_labels = { app = "atlantis" }
    }
    template {
      metadata {
        labels = { app = "atlantis" }
      }
      spec {
        automount_service_account_token = true
        service_account_name            = "atlantis"

        volume {
          name = "app-key"
          secret {
            secret_name = "github-app-key"
          }
        }

        container {
          name  = "atlantis"
          image = "runatlantis/atlantis:${local.image_tag}"
          args = [
            "server",
            "--gh-app-id",
            "97251",
            "--gh-app-key-file",
            "/etc/gh/atlantis-app-key",
            "--write-git-creds"
          ]

          volume_mount {
            name       = "app-key"
            mount_path = "/etc/gh"
            read_only  = true
          }

          dynamic "env" {
            for_each = local.env_map
            content {
              name  = env.key
              value = env.value
            }
          }

          env {
            name = "AWS_ACCESS_KEY_ID"
            value_from {
              secret_key_ref {
                name = "terraform-aws-keys"
                key  = "AWS_ACCESS_KEY_ID"
              }
            }
          }

          env {
            name = "AWS_SECRET_ACCESS_KEY"
            value_from {
              secret_key_ref {
                name = "terraform-aws-keys"
                key  = "AWS_SECRET_ACCESS_KEY"
              }
            }
          }

          env {
            name = "ATLANTIS_GH_WEBHOOK_SECRET"
            value_from {
              secret_key_ref {
                name = "github-webhook"
                key  = "webhook-secret"
              }
            }
          }

          port {
            name           = "atlantis"
            container_port = 4141
          }

          liveness_probe {
            http_get {
              path = "/healthz"
              port = 4141
            }
          }

          readiness_probe {
            http_get {
              path = "/healthz"
              port = 4141
            }
          }
        }
      }
    }
    strategy {
      type = "RollingUpdate"
    }
  }

  timeouts {
    create = "3m"
    update = "3m"
  }

  depends_on = [
    kubernetes_service_account.atlantis,
  ]

  lifecycle {
    ignore_changes = [metadata[0].annotations]
  }
}

resource "kubernetes_namespace" "atlantis" {
  metadata {
    name = "atlantis"
  }

  lifecycle {
    ignore_changes = [metadata[0].annotations]
  }
}

resource "kubernetes_service" "atlantis" {
  metadata {
    name      = "atlantis"
    namespace = "atlantis"
    labels    = { app = "atlantis" }
  }
  spec {
    port {
      protocol    = "TCP"
      port        = 4141
      target_port = "4141"
    }
    selector = { app = "atlantis" }

    type = "LoadBalancer"
  }

  lifecycle {
    ignore_changes = [metadata[0].annotations]
  }
}

resource "kubernetes_ingress" "atlantis" {
  metadata {
    name      = "atlantis"
    namespace = "atlantis"
    labels    = { app = "atlantis" }
  }
  spec {
    rule {
      host = local.atlantis_hostname
      http {
        path {
          path = "/*"
          backend {
            service_name = "ssl-redirect"
            service_port = "use-annotation"
          }
        }
        path {
          path = "/*"
          backend {
            service_name = "atlantis"
            service_port = "4141"
          }
        }
      }
    }
  }

  depends_on = [
    kubernetes_service.atlantis
  ]

  lifecycle {
    ignore_changes = [metadata[0].annotations]
  }
}

resource "kubernetes_service_account" "atlantis" {
  automount_service_account_token = true
  metadata {
    name      = "atlantis"
    namespace = "atlantis"
    labels    = { app = "atlantis" }
  }
}

resource "kubernetes_cluster_role_binding" "atlantis" {
  metadata {
    name = "atlantis"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "atlantis"
    namespace = "atlantis"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
}

resource "aws_ssm_parameter" "gh-webhook" {
  name  = "/global/atlantis/gh-webhook"
  type  = "SecureString"
  value = ""

  tags = local.default_tags

  lifecycle {
    ignore_changes = [value]
  }
}

resource "kubernetes_secret" "gh-webhook" {
  metadata {
    name      = "github-webhook"
    namespace = "atlantis"
  }

  data = {
    "app-id"         = "97251"
    "webhook-secret" = aws_ssm_parameter.gh-webhook.value
  }
}

resource "aws_ssm_parameter" "gh-app-key" {
  name  = "/global/atlantis/gh-app-key-rsa"
  type  = "SecureString"
  value = ""

  tags = local.default_tags

  lifecycle {
    ignore_changes = [value]
  }
}

resource "kubernetes_secret" "gh-app-key" {
  metadata {
    name      = "github-app-key"
    namespace = "atlantis"
  }

  data = {
    "atlantis-app-key" = aws_ssm_parameter.gh-app-key.value
  }
}