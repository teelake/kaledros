

resource "kubernetes_namespace" "aws_load_balancer_controller" {
  metadata {
    labels = {
      app = "kaledros-app"
    }
    name = "aws-load-balancer-controller"
  }
}

resource "kubernetes_namespace" "kaledros-application" {
  metadata {
    labels = {
      app = "kaledros-app"
    }
    name = "kaledros"
  }
}