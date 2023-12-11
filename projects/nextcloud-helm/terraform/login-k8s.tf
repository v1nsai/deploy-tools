provider "kubernetes" {
  config_path    = "~/.kube/config"
}

resource "kubernetes_namespace" "namespace" {
  metadata {
    name = "default"
  }
}