provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  token                  = data.aws_eks_cluster_auth.cluster.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
}


resource "kubernetes_namespace" "nginx" {
  metadata {
    name = "nginx"
  }
}
resource "kubernetes_deployment" "nginx" {
  metadata {
    name      = "nginx"
    namespace = kubernetes_namespace.nginx.metadata.0.name
  }
  spec {
    replicas = 2
    selector {
      match_labels = {
        app = "MyTestApp"
      }
    }
    template {
      metadata {
        labels = {
          app = "MyTestApp"
        }
      }
      spec {
        container {
          image = "nginx"
          name  = "nginx-container"
          port {
            container_port = 80
          }
        }
      }
    }
  }
}
resource "kubernetes_service" "nginx" {
  metadata {
    name      = "nginx"
    namespace = kubernetes_namespace.nginx.metadata.0.name
  }
  spec {
    selector = {
      app = kubernetes_deployment.nginx.spec.0.template.0.metadata.0.labels.app
    }
    type = "LoadBalancer"
    port {
      port        = 80
      target_port = 80
    }
  }
}



resource "kubernetes_namespace" "sample-nodejs" {
  metadata {
    name = "sample-nodejs"
  }
}

resource "kubernetes_deployment" "sample-nodejs" {
  metadata {
    name      = "sample-nodejs"
    namespace = kubernetes_namespace.sample-nodejs.metadata.0.name
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "sample-nodejs"
      }
    }
    template {
      metadata {
        labels = {
          app = "sample-nodejs"
        }
      }
      spec {
        container {
          image = "learnk8s/knote-js:1.0.0"
          name  = "sample-nodejs-container"
          port {
            container_port = 80
          }
          env {
              name = "MONGO_URL"
              value = "mongodb://mongo:27017/dev"

        }

      }
    }
  }
}
}

resource "kubernetes_service" "sample-nodejs" {
  metadata {
    name      = "sample-nodejs"
    namespace = kubernetes_namespace.sample-nodejs.metadata.0.name
  }
  spec {
    selector = {
      app = kubernetes_deployment.sample-nodejs.spec.0.template.0.metadata.0.labels.app
    }
    type = "LoadBalancer"
    port {
      port        = 80
      target_port = 3000
    }
  }
}

resource "kubernetes_deployment" "mongo" {
  metadata {
    name      = "mongo"
    namespace = kubernetes_namespace.sample-nodejs.metadata.0.name
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "mongo"
      }
    }
    template {
      metadata {
        labels = {
          app = "mongo"
        }
      }
      spec {
        container {
          image = "mongo:3.6.17-xenial"
          name  = "mongo-container"
          port {
            container_port = 27017
          }
      }
    }
  }
}
}


resource "kubernetes_service" "mongo" {
  metadata {
    name      = "mongo"
    namespace = kubernetes_namespace.sample-nodejs.metadata.0.name
  }
  spec {
    selector = {
      app = kubernetes_deployment.mongo.spec.0.template.0.metadata.0.labels.app
    }
    type = "ClusterIP"
    port {
      port        = 27017
      target_port = 27017
    }
  }
}
